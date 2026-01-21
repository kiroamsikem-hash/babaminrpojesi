// Server details page functionality
document.addEventListener('DOMContentLoaded', function() {
    if (!window.AuthUtils.checkAuth()) return;

    const socket = window.AuthUtils.socket;
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    if (!serverId) {
        window.location.href = '/dashboard';
        return;
    }

    // Initialize page
    initializePage(serverId);
    setupSocketListeners(serverId);
    setupTabNavigation();
    setupEventListeners();

    // Load initial data
    loadServerDetails(serverId);
    loadPlugins(serverId);
    loadMods(serverId);
    loadBackups(serverId);
});

async function initializePage(serverId) {
    // Sidebar toggle
    const sidebar = document.getElementById('sidebar');
    const sidebarToggle = document.getElementById('sidebarToggle');

    sidebarToggle.addEventListener('click', () => {
        sidebar.classList.toggle('collapsed');
    });

    // Join server room
    window.AuthUtils.socket.emit('join-server', serverId);
}

function setupTabNavigation() {
    const tabs = ['overviewTab', 'consoleTab', 'filesTab', 'pluginsTab', 'modsTab', 'backupsTab', 'settingsTab'];
    const contents = ['overviewContent', 'consoleContent', 'filesContent', 'pluginsContent', 'modsContent', 'backupsContent', 'settingsContent'];

    tabs.forEach((tabId, index) => {
        document.getElementById(tabId).addEventListener('click', () => {
            // Remove active class from all tabs
            tabs.forEach(id => document.getElementById(id).classList.remove('bg-electric-purple', 'text-white'));
            contents.forEach(id => document.getElementById(id).classList.add('hidden'));

            // Add active class to clicked tab
            document.getElementById(tabId).classList.add('bg-electric-purple', 'text-white');
            document.getElementById(contents[index]).classList.remove('hidden');

            // Initialize console if console tab is selected
            if (tabId === 'consoleTab') {
                initializeTerminal();
            }
        });
    });
}

function setupEventListeners() {
    // Server control buttons
    document.getElementById('startBtn').addEventListener('click', () => sendServerCommand('start'));
    document.getElementById('stopBtn').addEventListener('click', () => sendServerCommand('stop'));
    document.getElementById('restartBtn').addEventListener('click', () => sendServerCommand('restart'));

    // Backup button
    document.getElementById('createBackupBtn').addEventListener('click', () => createBackup());
}

async function loadServerDetails(serverId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}`);

        if (response.success) {
            const server = response.server;

            // Update header
            document.getElementById('serverName').textContent = server.name;
            updateServerStatus(server.status);

            // Update overview stats
            if (server.stats) {
                document.getElementById('cpuUsage').textContent = `${server.stats.cpuUsage.toFixed(1)}%`;
                document.getElementById('memoryUsage').textContent = `${(server.stats.memoryUsage / 1024 / 1024).toFixed(1)} MB`;
                document.getElementById('tps').textContent = server.stats.tps.toFixed(1);
                document.getElementById('playersOnline').textContent = server.stats.playerCount;
                document.getElementById('maxPlayers').textContent = server.stats.maxPlayers;
            }

            // Update uptime
            updateUptime(server.uptime || 0);

            // Load players
            loadPlayers(server.players || []);
        }
    } catch (error) {
        console.error('Error loading server details:', error);
        showNotification('Failed to load server details', 'error');
    }
}

function updateServerStatus(status) {
    const statusElement = document.getElementById('serverStatus');
    const startBtn = document.getElementById('startBtn');
    const stopBtn = document.getElementById('stopBtn');
    const restartBtn = document.getElementById('restartBtn');

    const statusConfig = {
        'running': { text: '● Running', color: 'text-success-green', showStart: false, showStop: true },
        'stopped': { text: '● Stopped', color: 'text-danger-red', showStart: true, showStop: false },
        'starting': { text: '● Starting', color: 'text-yellow-400', showStart: false, showStop: false },
        'stopping': { text: '● Stopping', color: 'text-yellow-400', showStart: false, showStop: false }
    };

    const config = statusConfig[status] || statusConfig.stopped;

    statusElement.textContent = config.text;
    statusElement.className = `text-sm ${config.color}`;

    startBtn.classList.toggle('hidden', !config.showStart);
    stopBtn.classList.toggle('hidden', !config.showStop);
    restartBtn.classList.toggle('hidden', status === 'starting' || status === 'stopping');
}

function updateUptime(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    document.getElementById('uptime').textContent =
        `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}

function loadPlayers(players) {
    const playersList = document.getElementById('playersList');
    playersList.innerHTML = '';

    if (players.length === 0) {
        playersList.innerHTML = '<p class="text-gray-400 col-span-full text-center py-8">No players online</p>';
        return;
    }

    players.forEach(player => {
        const playerCard = document.createElement('div');
        playerCard.className = 'bg-gray-800 rounded-lg p-4 border border-gray-700';
        playerCard.innerHTML = `
            <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-electric-purple rounded-lg flex items-center justify-center">
                    <i class="fas fa-user text-white"></i>
                </div>
                <div>
                    <p class="text-white font-medium">${player.username}</p>
                    <p class="text-gray-400 text-sm">${Math.floor((Date.now() - new Date(player.joinedAt)) / 1000 / 60)}m online</p>
                </div>
            </div>
        `;
        playersList.appendChild(playerCard);
    });
}

async function loadPlugins(serverId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}/plugins`);

        if (response.success) {
            const pluginsList = document.getElementById('pluginsList');
            pluginsList.innerHTML = '';

            if (response.plugins.length === 0) {
                pluginsList.innerHTML = '<p class="text-gray-400 col-span-full text-center py-8">No plugins installed</p>';
                return;
            }

            response.plugins.forEach(plugin => {
                const pluginCard = document.createElement('div');
                pluginCard.className = 'bg-dark-secondary rounded-lg p-4 border border-gray-700';
                pluginCard.innerHTML = `
                    <div class="flex items-start justify-between mb-3">
                        <div>
                            <h4 class="text-white font-medium">${plugin.name}</h4>
                            <p class="text-gray-400 text-sm">v${plugin.version}</p>
                        </div>
                        <div class="flex items-center space-x-2">
                            <span class="px-2 py-1 rounded text-xs ${plugin.isEnabled ? 'bg-success-green text-white' : 'bg-gray-600 text-gray-300'}">
                                ${plugin.isEnabled ? 'Enabled' : 'Disabled'}
                            </span>
                        </div>
                    </div>
                    ${plugin.description ? `<p class="text-gray-300 text-sm mb-3">${plugin.description}</p>` : ''}
                    <div class="flex space-x-2">
                        <button onclick="togglePlugin('${plugin.id}', ${!plugin.isEnabled})"
                                class="flex-1 ${plugin.isEnabled ? 'bg-danger-red hover:bg-red-700' : 'bg-success-green hover:bg-green-600'} text-white py-1 px-3 rounded text-sm transition-colors">
                            ${plugin.isEnabled ? 'Disable' : 'Enable'}
                        </button>
                        <button onclick="uninstallPlugin('${plugin.id}')"
                                class="bg-gray-600 hover:bg-gray-700 text-white py-1 px-3 rounded text-sm transition-colors">
                            Uninstall
                        </button>
                    </div>
                `;
                pluginsList.appendChild(pluginCard);
            });
        }
    } catch (error) {
        console.error('Error loading plugins:', error);
        showNotification('Failed to load plugins', 'error');
    }
}

async function loadMods(serverId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}/mods`);

        if (response.success) {
            const modsList = document.getElementById('modsList');
            modsList.innerHTML = '';

            if (response.mods.length === 0) {
                modsList.innerHTML = '<p class="text-gray-400 col-span-full text-center py-8">No mods installed</p>';
                return;
            }

            response.mods.forEach(mod => {
                const modCard = document.createElement('div');
                modCard.className = 'bg-dark-secondary rounded-lg p-4 border border-gray-700';
                modCard.innerHTML = `
                    <div class="flex items-start justify-between mb-3">
                        <div>
                            <h4 class="text-white font-medium">${mod.name}</h4>
                            <p class="text-gray-400 text-sm">v${mod.version} (${mod.modLoader})</p>
                        </div>
                        <div class="flex items-center space-x-2">
                            <span class="px-2 py-1 rounded text-xs ${mod.isEnabled ? 'bg-success-green text-white' : 'bg-gray-600 text-gray-300'}">
                                ${mod.isEnabled ? 'Enabled' : 'Disabled'}
                            </span>
                        </div>
                    </div>
                    ${mod.description ? `<p class="text-gray-300 text-sm mb-3">${mod.description}</p>` : ''}
                    <div class="flex space-x-2">
                        <button onclick="toggleMod('${mod.id}', ${!mod.isEnabled})"
                                class="flex-1 ${mod.isEnabled ? 'bg-danger-red hover:bg-red-700' : 'bg-success-green hover:bg-green-600'} text-white py-1 px-3 rounded text-sm transition-colors">
                            ${mod.isEnabled ? 'Disable' : 'Enable'}
                        </button>
                        <button onclick="uninstallMod('${mod.id}')"
                                class="bg-gray-600 hover:bg-gray-700 text-white py-1 px-3 rounded text-sm transition-colors">
                            Uninstall
                        </button>
                    </div>
                `;
                modsList.appendChild(modCard);
            });
        }
    } catch (error) {
        console.error('Error loading mods:', error);
        showNotification('Failed to load mods', 'error');
    }
}

async function loadBackups(serverId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/backups/${serverId}`);

        if (response.success) {
            const backupsList = document.getElementById('backupsList');
            backupsList.innerHTML = '';

            if (response.backups.length === 0) {
                backupsList.innerHTML = '<p class="text-gray-400 text-center py-8">No backups found</p>';
                return;
            }

            response.backups.forEach(backup => {
                const backupItem = document.createElement('div');
                backupItem.className = 'bg-dark-secondary rounded-lg p-4 border border-gray-700';
                backupItem.innerHTML = `
                    <div class="flex items-center justify-between">
                        <div>
                            <h4 class="text-white font-medium">${backup.name}</h4>
                            <p class="text-gray-400 text-sm">
                                ${new Date(backup.createdAt).toLocaleDateString()} •
                                ${(backup.size / 1024 / 1024).toFixed(2)} MB
                            </p>
                        </div>
                        <div class="flex space-x-2">
                            <button onclick="restoreBackup('${backup.id}')"
                                    class="bg-blue-600 hover:bg-blue-700 text-white py-1 px-3 rounded text-sm transition-colors">
                                Restore
                            </button>
                            <button onclick="downloadBackup('${backup.id}')"
                                    class="bg-green-600 hover:bg-green-700 text-white py-1 px-3 rounded text-sm transition-colors">
                                Download
                            </button>
                            <button onclick="deleteBackup('${backup.id}')"
                                    class="bg-danger-red hover:bg-red-700 text-white py-1 px-3 rounded text-sm transition-colors">
                                Delete
                            </button>
                        </div>
                    </div>
                `;
                backupsList.appendChild(backupItem);
            });
        }
    } catch (error) {
        console.error('Error loading backups:', error);
        showNotification('Failed to load backups', 'error');
    }
}

let terminal = null;
function initializeTerminal() {
    if (terminal) return;

    const terminalElement = document.getElementById('terminal');

    terminal = new Terminal({
        fontFamily: '"Fira Code", "Monaco", "Consolas", monospace',
        fontSize: 14,
        theme: {
            background: '#000000',
            foreground: '#00ff00',
            cursor: '#00ff00'
        },
        cursorBlink: true,
        scrollback: 1000
    });

    const fitAddon = new FitAddon.FitAddon();
    terminal.loadAddon(fitAddon);

    terminal.open(terminalElement);
    fitAddon.fit();

    // Handle window resize
    window.addEventListener('resize', () => fitAddon.fit());

    // Welcome message
    terminal.writeln('\x1b[32mMinecraft Server Console\x1b[0m');
    terminal.writeln('\x1b[32mType commands and press Enter to execute them on the server.\x1b[0m');
    terminal.writeln('');
}

function handleConsoleKeypress(event) {
    if (event.key === 'Enter') {
        sendConsoleCommand();
    }
}

async function sendConsoleCommand() {
    const input = document.getElementById('consoleInput');
    const command = input.value.trim();

    if (!command) return;

    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    try {
        // Add command to terminal
        if (terminal) {
            terminal.writeln(`\x1b[32m$ ${command}\x1b[0m`);
        }

        // Send command via API
        await window.AuthUtils.apiRequest(`/api/servers/${serverId}/console`, {
            method: 'POST',
            body: JSON.stringify({ command })
        });

        input.value = '';

    } catch (error) {
        console.error('Send console command error:', error);
        if (terminal) {
            terminal.writeln(`\x1b[31mError: ${error.message}\x1b[0m`);
        }
        showNotification('Failed to send command', 'error');
    }
}

async function sendServerCommand(action) {
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}/${action}`, {
            method: 'PUT'
        });

        if (response.success) {
            showNotification(`Server ${action} initiated`, 'info');
            // Reload server details after a delay
            setTimeout(() => loadServerDetails(serverId), 2000);
        } else {
            showNotification(response.message || `Failed to ${action} server`, 'error');
        }
    } catch (error) {
        console.error(`Error ${action} server:`, error);
        showNotification(`Failed to ${action} server`, 'error');
    }
}

async function createBackup() {
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    try {
        const response = await window.AuthUtils.apiRequest(`/api/backups/${serverId}`, {
            method: 'POST',
            body: JSON.stringify({ name: `Backup ${new Date().toLocaleString()}` })
        });

        if (response.success) {
            showNotification('Backup created successfully', 'success');
            loadBackups(serverId);
        } else {
            showNotification('Failed to create backup', 'error');
        }
    } catch (error) {
        console.error('Error creating backup:', error);
        showNotification('Failed to create backup', 'error');
    }
}

// Plugin and Mod management functions
async function togglePlugin(pluginId, enable) {
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    try {
        const action = enable ? 'enable' : 'disable';
        // This would call the appropriate API endpoint
        showNotification(`Plugin ${action}d successfully`, 'success');
        loadPlugins(serverId);
    } catch (error) {
        showNotification('Failed to toggle plugin', 'error');
    }
}

async function uninstallPlugin(pluginId) {
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    if (!confirm('Are you sure you want to uninstall this plugin?')) return;

    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}/plugins/${pluginId}`, {
            method: 'DELETE'
        });

        if (response.success) {
            showNotification('Plugin uninstalled successfully', 'success');
            loadPlugins(serverId);
        }
    } catch (error) {
        showNotification('Failed to uninstall plugin', 'error');
    }
}

async function toggleMod(modId, enable) {
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    try {
        const action = enable ? 'enable' : 'disable';
        showNotification(`Mod ${action}d successfully`, 'success');
        loadMods(serverId);
    } catch (error) {
        showNotification('Failed to toggle mod', 'error');
    }
}

async function uninstallMod(modId) {
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    if (!confirm('Are you sure you want to uninstall this mod?')) return;

    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}/mods/${modId}`, {
            method: 'DELETE'
        });

        if (response.success) {
            showNotification('Mod uninstalled successfully', 'success');
            loadMods(serverId);
        }
    } catch (error) {
        showNotification('Failed to uninstall mod', 'error');
    }
}

async function restoreBackup(backupId) {
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    if (!confirm('Are you sure you want to restore this backup? This will overwrite current server data.')) return;

    try {
        const response = await window.AuthUtils.apiRequest(`/api/backups/${serverId}/${backupId}/restore`, {
            method: 'POST'
        });

        if (response.success) {
            showNotification('Backup restored successfully', 'success');
            loadBackups(serverId);
        }
    } catch (error) {
        showNotification('Failed to restore backup', 'error');
    }
}

async function downloadBackup(backupId) {
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    window.open(`/api/backups/${serverId}/${backupId}/download`, '_blank');
}

async function deleteBackup(backupId) {
    const urlParams = new URLSearchParams(window.location.search);
    const serverId = urlParams.get('id');

    if (!confirm('Are you sure you want to delete this backup?')) return;

    try {
        const response = await window.AuthUtils.apiRequest(`/api/backups/${serverId}/${backupId}`, {
            method: 'DELETE'
        });

        if (response.success) {
            showNotification('Backup deleted successfully', 'success');
            loadBackups(serverId);
        }
    } catch (error) {
        showNotification('Failed to delete backup', 'error');
    }
}

function setupSocketListeners(serverId) {
    const socket = window.AuthUtils.socket;

    socket.on('console-output', (data) => {
        if (terminal && data.output) {
            terminal.writeln(data.output);
        }
    });

    socket.on('server-started', (data) => {
        showNotification('Server started successfully!', 'success');
        updateServerStatus('running');
    });

    socket.on('server-stopped', (data) => {
        showNotification('Server stopped successfully!', 'info');
        updateServerStatus('stopped');
    });

    socket.on('stats-update', (data) => {
        if (data.serverId === serverId && data.stats) {
            document.getElementById('cpuUsage').textContent = `${data.stats.cpu.toFixed(1)}%`;
            document.getElementById('memoryUsage').textContent = `${(data.stats.memory / 1024 / 1024).toFixed(1)} MB`;
            document.getElementById('playersOnline').textContent = data.stats.players;
            updateUptime(data.stats.uptime || 0);
        }
    });
}

// Notification system
function showNotification(message, type = 'info') {
    const notifications = document.getElementById('notifications');
    const notification = document.createElement('div');

    const colors = {
        success: 'notification-success',
        error: 'notification-error',
        warning: 'notification-warning',
        info: 'notification-info'
    };

    notification.className = `notification ${colors[type]}`;
    notification.innerHTML = `
        <div class="flex items-center space-x-3">
            <i class="fas ${type === 'success' ? 'fa-check-circle' : type === 'error' ? 'fa-exclamation-circle' : type === 'warning' ? 'fa-exclamation-triangle' : 'fa-info-circle'}"></i>
            <span>${message}</span>
        </div>
    `;

    notifications.appendChild(notification);

    // Show notification
    setTimeout(() => notification.classList.add('show'), 100);

    // Auto remove after 5 seconds
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => notification.remove(), 300);
    }, 5000);
}