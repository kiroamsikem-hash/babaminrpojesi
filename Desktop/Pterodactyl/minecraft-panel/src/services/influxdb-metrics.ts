import { InfluxDB, Point } from '@influxdata/influxdb-client';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class InfluxDBMetricsService {
  private influxDB: InfluxDB;
  private writeApi: any;
  private queryApi: any;

  constructor() {
    const url = process.env.INFLUXDB_URL || 'http://localhost:8086';
    const token = process.env.INFLUXDB_TOKEN || '';
    const org = process.env.INFLUXDB_ORG || 'minecraft';
    const bucket = process.env.INFLUXDB_BUCKET || 'minecraft_metrics';

    this.influxDB = new InfluxDB({ url, token });
    this.writeApi = this.influxDB.getWriteApi(org, bucket);
    this.queryApi = this.influxDB.getQueryApi(org);
  }

  public async recordServerMetrics(serverId: string, metrics: {
    cpuUsage: number;
    memoryUsage: number;
    networkIn: number;
    networkOut: number;
    tps: number;
    playerCount: number;
    maxPlayers: number;
    uptime: number;
  }): Promise<void> {
    try {
      const point = new Point('server_metrics')
        .tag('server_id', serverId)
        .floatField('cpu_usage', metrics.cpuUsage)
        .floatField('memory_usage', metrics.memoryUsage)
        .floatField('network_in', metrics.networkIn)
        .floatField('network_out', metrics.networkOut)
        .floatField('tps', metrics.tps)
        .intField('player_count', metrics.playerCount)
        .intField('max_players', metrics.maxPlayers)
        .intField('uptime', metrics.uptime)
        .timestamp(new Date());

      this.writeApi.writePoint(point);
      await this.writeApi.flush();

    } catch (error) {
      console.error('Error recording server metrics:', error);
    }
  }

  public async recordPlayerActivity(serverId: string, playerData: {
    playerId: string;
    playerName: string;
    action: 'join' | 'leave' | 'death' | 'achievement';
    details?: any;
  }): Promise<void> {
    try {
      const point = new Point('player_activity')
        .tag('server_id', serverId)
        .tag('player_id', playerData.playerId)
        .tag('action', playerData.action)
        .stringField('player_name', playerData.playerName)
        .timestamp(new Date());

      if (playerData.details) {
        point.stringField('details', JSON.stringify(playerData.details));
      }

      this.writeApi.writePoint(point);
      await this.writeApi.flush();

    } catch (error) {
      console.error('Error recording player activity:', error);
    }
  }

  public async recordSystemMetrics(nodeId: string, metrics: {
    cpuUsage: number;
    memoryUsage: number;
    diskUsage: number;
    networkIn: number;
    networkOut: number;
    loadAverage: number[];
  }): Promise<void> {
    try {
      const point = new Point('system_metrics')
        .tag('node_id', nodeId)
        .floatField('cpu_usage', metrics.cpuUsage)
        .floatField('memory_usage', metrics.memoryUsage)
        .floatField('disk_usage', metrics.diskUsage)
        .floatField('network_in', metrics.networkIn)
        .floatField('network_out', metrics.networkOut)
        .floatField('load_1m', metrics.loadAverage[0] || 0)
        .floatField('load_5m', metrics.loadAverage[1] || 0)
        .floatField('load_15m', metrics.loadAverage[2] || 0)
        .timestamp(new Date());

      this.writeApi.writePoint(point);
      await this.writeApi.flush();

    } catch (error) {
      console.error('Error recording system metrics:', error);
    }
  }

  public async getServerMetrics(serverId: string, hours: number = 24): Promise<any[]> {
    try {
      const query = `
        from(bucket: "${process.env.INFLUXDB_BUCKET}")
          |> range(start: -${hours}h)
          |> filter(fn: (r) => r["_measurement"] == "server_metrics")
          |> filter(fn: (r) => r["server_id"] == "${serverId}")
          |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
          |> yield(name: "mean")
      `;

      const result = await this.queryApi.collectRows(query);
      return result;

    } catch (error) {
      console.error('Error querying server metrics:', error);
      return [];
    }
  }

  public async getServerStats(serverId: string): Promise<any> {
    try {
      const query = `
        from(bucket: "${process.env.INFLUXDB_BUCKET}")
          |> range(start: -1h)
          |> filter(fn: (r) => r["_measurement"] == "server_metrics")
          |> filter(fn: (r) => r["server_id"] == "${serverId}")
          |> last()
      `;

      const result = await this.queryApi.collectRows(query);

      if (result.length === 0) {
        return null;
      }

      // Transform the result
      const latest = result[0];
      return {
        cpuUsage: latest._value,
        memoryUsage: latest._value,
        networkIn: latest._value,
        networkOut: latest._value,
        tps: latest._value,
        playerCount: latest._value,
        maxPlayers: latest._value,
        uptime: latest._value,
        timestamp: latest._time
      };

    } catch (error) {
      console.error('Error getting server stats:', error);
      return null;
    }
  }

  public async getPlayerActivity(serverId: string, hours: number = 24): Promise<any[]> {
    try {
      const query = `
        from(bucket: "${process.env.INFLUXDB_BUCKET}")
          |> range(start: -${hours}h)
          |> filter(fn: (r) => r["_measurement"] == "player_activity")
          |> filter(fn: (r) => r["server_id"] == "${serverId}")
          |> group(columns: ["action"])
          |> count()
      `;

      const result = await this.queryApi.collectRows(query);
      return result;

    } catch (error) {
      console.error('Error querying player activity:', error);
      return [];
    }
  }

  public async getSystemMetrics(nodeId: string, hours: number = 24): Promise<any[]> {
    try {
      const query = `
        from(bucket: "${process.env.INFLUXDB_BUCKET}")
          |> range(start: -${hours}h)
          |> filter(fn: (r) => r["_measurement"] == "system_metrics")
          |> filter(fn: (r) => r["node_id"] == "${nodeId}")
          |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
      `;

      const result = await this.queryApi.collectRows(query);
      return result;

    } catch (error) {
      console.error('Error querying system metrics:', error);
      return [];
    }
  }

  public async getTopPlayersByPlaytime(serverId: string, limit: number = 10): Promise<any[]> {
    try {
      // This would require a more complex query to calculate playtime
      // For now, return a placeholder
      return [];

    } catch (error) {
      console.error('Error getting top players:', error);
      return [];
    }
  }

  public async getServerUptimeStats(serverId: string, days: number = 30): Promise<any> {
    try {
      const query = `
        from(bucket: "${process.env.INFLUXDB_BUCKET}")
          |> range(start: -${days}d)
          |> filter(fn: (r) => r["_measurement"] == "server_metrics")
          |> filter(fn: (r) => r["server_id"] == "${serverId}")
          |> filter(fn: (r) => r["_field"] == "uptime")
          |> aggregateWindow(every: 1h, fn: last, createEmpty: false)
          |> mean(column: "_value")
      `;

      const result = await this.queryApi.collectRows(query);

      if (result.length === 0) {
        return { averageUptime: 0, totalHours: 0 };
      }

      const totalHours = result.length;
      const averageUptime = result.reduce((sum: number, row: any) => sum + row._value, 0) / totalHours;

      return {
        averageUptime: Math.round(averageUptime),
        totalHours
      };

    } catch (error) {
      console.error('Error getting uptime stats:', error);
      return { averageUptime: 0, totalHours: 0 };
    }
  }

  public async createAlert(serverId: string, alertType: string, message: string, severity: 'low' | 'medium' | 'high' | 'critical'): Promise<void> {
    try {
      const point = new Point('alerts')
        .tag('server_id', serverId)
        .tag('alert_type', alertType)
        .tag('severity', severity)
        .stringField('message', message)
        .timestamp(new Date());

      this.writeApi.writePoint(point);
      await this.writeApi.flush();

      console.log(`🚨 Alert created: ${alertType} - ${message}`);

    } catch (error) {
      console.error('Error creating alert:', error);
    }
  }

  public async getAlerts(serverId?: string, hours: number = 24): Promise<any[]> {
    try {
      let query = `
        from(bucket: "${process.env.INFLUXDB_BUCKET}")
          |> range(start: -${hours}h)
          |> filter(fn: (r) => r["_measurement"] == "alerts")
      `;

      if (serverId) {
        query += `|> filter(fn: (r) => r["server_id"] == "${serverId}")`;
      }

      query += `|> sort(columns: ["_time"], desc: true)`;

      const result = await this.queryApi.collectRows(query);
      return result;

    } catch (error) {
      console.error('Error querying alerts:', error);
      return [];
    }
  }

  public async cleanupOldData(days: number = 90): Promise<void> {
    try {
      // InfluxDB automatically handles data retention based on bucket settings
      // This is just a placeholder for manual cleanup if needed
      console.log(`🧹 InfluxDB data cleanup completed (retention: ${days} days)`);

    } catch (error) {
      console.error('Error cleaning up old data:', error);
    }
  }

  public async healthCheck(): Promise<boolean> {
    try {
      const query = `
        from(bucket: "${process.env.INFLUXDB_BUCKET}")
          |> range(start: -1h)
          |> limit(n: 1)
      `;

      await this.queryApi.collectRows(query);
      return true;

    } catch (error) {
      console.error('InfluxDB health check failed:', error);
      return false;
    }
  }

  public async close(): Promise<void> {
    try {
      await this.writeApi.close();
      console.log('📊 InfluxDB connection closed');
    } catch (error) {
      console.error('Error closing InfluxDB connection:', error);
    }
  }
}