// Dashboard functionality with Skyport design
document.addEventListener('DOMContentLoaded', function() {
    if (!window.AuthUtils.checkAuth()) return;

    const user = window.AuthUtils.getUser();
    const socket = window.AuthUtils.socket;

    // Update user name
    document.getElementById('userName').textContent = user.username;

    // Show admin link if user is admin
    if (user.role === 'admin') {
        document.getElementById('adminLink').style.display = 'flex';
    }

    // Sidebar functionality
    const sidebar = document.getElementById('sidebar');
    const sidebarToggle = document.getElementById('sidebarToggle');

    sidebarToggle.addEventListener('click', () => {
        sidebar.classList.toggle('collapsed');
    });

    // Navigation
    document.getElementById('adminLink').addEventListener('click', () => {
        window.location.href = '/admin';
    });

    document.getElementById('logoutBtn').addEventListener('click', () => {
        window.AuthUtils.logout();
    });

    // Load dashboard data
    loadDashboardData();
    loadServers();

    // Modal controls
    const createServerModal = document.getElementById('createServerModal');
    const serverDetailsModal = document.getElementById('serverDetailsModal');

    document.getElementById('createServerBtn').addEventListener('click', () => {
        createServerModal.classList.remove('hidden');
    });

    document.querySelectorAll('.close-modal').forEach(button => {
        button.addEventListener('click', () => {
            createServerModal.classList.add('hidden');
            serverDetailsModal.classList.add('hidden');
        });
    });

    // Close modal when clicking outside
    createServerModal.addEventListener('click', (event) => {
        if (event.target === createServerModal) {
            createServerModal.classList.add('hidden');
        }
    });

    serverDetailsModal.addEventListener('click', (event) => {
        if (event.target === serverDetailsModal) {
            serverDetailsModal.classList.add('hidden');
        }
    });

    // Create server form
    document.getElementById('createServerForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = {
            name: document.getElementById('serverName').value,
            description: document.getElementById('serverDescription').value,
            memory: document.getElementById('serverMemory').value,
            disk: document.getElementById('serverDisk').value,
            version: document.getElementById('serverVersion').value
        };

        try {
            const response = await window.AuthUtils.apiRequest('/api/servers', {
                method: 'POST',
                body: JSON.stringify(formData)
            });

            if (response.success) {
                createServerModal.classList.add('hidden');
                document.getElementById('createServerForm').reset();
                loadServers();
                loadDashboardData();
                showNotification('Server created successfully!', 'success');
            } else {
                showNotification(response.message || 'Failed to create server', 'error');
            }
        } catch (error) {
            console.error('Create server error:', error);
            showNotification('Failed to create server. Please try again.', 'error');
        }
    });
});

async function loadDashboardData() {
    try {
        const response = await window.AuthUtils.apiRequest('/api/servers');

        if (response.success) {
            const servers = response.servers;
            const runningServers = servers.filter(s => s.status === 'running').length;
            const totalPlayers = servers.reduce((sum, server) => sum + server.players.online, 0);

            document.getElementById('serverCount').textContent = servers.length;
            document.getElementById('runningServers').textContent = runningServers;
            document.getElementById('stoppedServers').textContent = servers.length - runningServers;
            document.getElementById('totalPlayers').textContent = totalPlayers;
        }
    } catch (error) {
        console.error('Load dashboard data error:', error);
    }
}

async function loadServers() {
    try {
        const response = await window.AuthUtils.apiRequest('/api/servers');

        if (response.success) {
            const serversContainer = document.getElementById('serversList');
            serversContainer.innerHTML = '';

            if (response.servers.length === 0) {
                serversContainer.innerHTML = `
                    <div class="col-span-full text-center py-12">
                        <div class="w-16 h-16 bg-gray-700 rounded-full flex items-center justify-center mx-auto mb-4">
                            <i class="fas fa-server text-gray-400 text-2xl"></i>
                        </div>
                        <h3 class="text-xl font-semibold text-gray-300 mb-2">No servers found</h3>
                        <p class="text-gray-400 mb-4">Create your first Minecraft server to get started</p>
                        <button onclick="document.getElementById('createServerBtn').click()"
                                class="bg-electric-purple hover:bg-purple-700 text-white px-6 py-3 rounded-lg transition-colors glow-electric">
                            Create Server
                        </button>
                    </div>
                `;
                return;
            }

            response.servers.forEach(server => {
                const serverCard = createServerCard(server);
                serversContainer.appendChild(serverCard);
            });
        }
    } catch (error) {
        console.error('Load servers error:', error);
        showNotification('Failed to load servers', 'error');
    }
}

function createServerCard(server) {
    const card = document.createElement('div');
    card.className = 'server-card bg-dark-secondary rounded-lg p-6 border border-gray-700 hover:border-electric-purple transition-colors';

    const statusClass = `status-${server.status}`;
    const statusText = server.status.charAt(0).toUpperCase() + server.status.slice(1);
    const statusColor = {
        'running': 'text-success-green',
        'stopped': 'text-danger-red',
        'starting': 'text-yellow-400',
        'stopping': 'text-yellow-400'
    }[server.status] || 'text-gray-400';

    const statusGlow = {
        'running': 'glow-success',
        'stopped': '',
        'starting': 'glow-pulse',
        'stopping': 'glow-pulse'
    }[server.status] || '';

    card.innerHTML = `
        <div class="flex items-start justify-between mb-4">
            <div class="flex items-center space-x-3">
                <div class="w-10 h-10 bg-electric-purple rounded-lg flex items-center justify-center ${statusGlow}">
                    <i class="fas fa-cube text-white"></i>
                </div>
                <div>
                    <h3 class="text-lg font-semibold text-white">${server.name}</h3>
                    <p class="text-sm ${statusColor} font-medium status-indicator">${statusText}</p>
                </div>
            </div>
            <div class="flex space-x-2">
                <button onclick="viewServerDetails('${server._id}')"
                        class="text-gray-400 hover:text-white transition-colors p-2 rounded-lg hover:bg-gray-700"
                        title="View Details">
                    <i class="fas fa-eye"></i>
                </button>
                <button onclick="openFileManager('${server._id}')"
                        class="text-gray-400 hover:text-white transition-colors p-2 rounded-lg hover:bg-gray-700"
                        title="File Manager">
                    <i class="fas fa-folder"></i>
                </button>
                <button onclick="createBackup('${server._id}')"
                        class="text-gray-400 hover:text-white transition-colors p-2 rounded-lg hover:bg-gray-700"
                        title="Create Backup">
                    <i class="fas fa-archive"></i>
                </button>
            </div>
        </div>

        <div class="space-y-3 mb-4">
            <div class="flex justify-between text-sm">
                <span class="text-gray-400">Version:</span>
                <span class="text-white">${server.version}</span>
            </div>
            <div class="flex justify-between text-sm">
                <span class="text-gray-400">Memory:</span>
                <span class="text-white">${server.memory}</span>
            </div>
            <div class="flex justify-between text-sm">
                <span class="text-gray-400">Players:</span>
                <span class="text-white">${server.players.online}/${server.players.max}</span>
            </div>
            <div class="flex justify-between text-sm">
                <span class="text-gray-400">Port:</span>
                <span class="text-white">${server.port}</span>
            </div>
        </div>

        <div class="flex space-x-2">
            ${server.status === 'running' ?
                `<button onclick="stopServer('${server._id}')"
                         class="flex-1 bg-danger-red hover:bg-red-700 text-white py-2 px-4 rounded-lg transition-colors flex items-center justify-center space-x-2">
                    <i class="fas fa-stop"></i>
                    <span>Stop</span>
                </button>` :
                `<button onclick="startServer('${server._id}')"
                         class="flex-1 bg-success-green hover:bg-green-600 text-white py-2 px-4 rounded-lg transition-colors flex items-center justify-center space-x-2">
                    <i class="fas fa-play"></i>
                    <span>Start</span>
                </button>`
            }
            <button onclick="restartServer('${server._id}')"
                    class="bg-yellow-600 hover:bg-yellow-700 text-white py-2 px-4 rounded-lg transition-colors flex items-center justify-center space-x-2"
                    ${server.status !== 'running' ? 'disabled class="opacity-50 cursor-not-allowed"' : ''}>
                <i class="fas fa-redo"></i>
                <span>Restart</span>
            </button>
            <button onclick="deleteServer('${server._id}')"
                    class="bg-gray-600 hover:bg-gray-700 text-white py-2 px-4 rounded-lg transition-colors flex items-center justify-center">
                <i class="fas fa-trash"></i>
            </button>
        </div>
    `;

    return card;
}

async function startServer(serverId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}/start`, {
            method: 'PUT'
        });

        if (response.success) {
            loadServers();
            loadDashboardData();
            showNotification('Server starting...', 'info');
        } else {
            showNotification(response.message || 'Failed to start server', 'error');
        }
    } catch (error) {
        console.error('Start server error:', error);
        showNotification('Failed to start server', 'error');
    }
}

async function stopServer(serverId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}/stop`, {
            method: 'PUT'
        });

        if (response.success) {
            loadServers();
            loadDashboardData();
            showNotification('Server stopping...', 'info');
        } else {
            showNotification(response.message || 'Failed to stop server', 'error');
        }
    } catch (error) {
        console.error('Stop server error:', error);
        showNotification('Failed to stop server', 'error');
    }
}

async function restartServer(serverId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}/restart`, {
            method: 'PUT'
        });

        if (response.success) {
            loadServers();
            loadDashboardData();
            showNotification('Server restarting...', 'info');
        } else {
            showNotification(response.message || 'Failed to restart server', 'error');
        }
    } catch (error) {
        console.error('Restart server error:', error);
        showNotification('Failed to restart server', 'error');
    }
}

async function createBackup(serverId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/backups/${serverId}`, {
            method: 'POST'
        });

        if (response.success) {
            showNotification('Backup created successfully!', 'success');
        } else {
            showNotification(response.message || 'Failed to create backup', 'error');
        }
    } catch (error) {
        console.error('Create backup error:', error);
        showNotification('Failed to create backup', 'error');
    }
}

async function openFileManager(serverId) {
    window.open(`/files/${serverId}`, '_blank');
}

async function viewServerDetails(serverId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}`);

        if (response.success) {
            const server = response.server;
            const modal = document.getElementById('serverDetailsModal');
            const details = document.getElementById('serverDetails');

            const statusColor = {
                'running': 'text-success-green',
                'stopped': 'text-danger-red',
                'starting': 'text-yellow-400',
                'stopping': 'text-yellow-400'
            }[server.status] || 'text-gray-400';

            details.innerHTML = `
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <!-- Server Info -->
                    <div class="lg:col-span-1 space-y-6">
                        <div class="bg-dark-primary rounded-lg p-6 border border-gray-700">
                            <div class="flex items-center space-x-3 mb-4">
                                <div class="w-12 h-12 bg-electric-purple rounded-lg flex items-center justify-center">
                                    <i class="fas fa-server text-white"></i>
                                </div>
                                <div>
                                    <h3 class="text-xl font-semibold text-white">${server.name}</h3>
                                    <p class="${statusColor} font-medium">● ${server.status.charAt(0).toUpperCase() + server.status.slice(1)}</p>
                                </div>
                            </div>

                            <div class="space-y-3">
                                <div class="flex justify-between">
                                    <span class="text-gray-400">Version:</span>
                                    <span class="text-white">${server.version}</span>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-400">Memory:</span>
                                    <span class="text-white">${server.memory}</span>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-400">Disk:</span>
                                    <span class="text-white">${server.disk} MB</span>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-400">Port:</span>
                                    <span class="text-white">${server.port}</span>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-400">Players:</span>
                                    <span class="text-white">${server.players.online}/${server.players.max}</span>
                                </div>
                            </div>

                            <div class="mt-4 flex space-x-2">
                                ${server.status === 'running' ?
                                    `<button onclick="stopServer('${server._id}')" class="flex-1 bg-danger-red hover:bg-red-700 text-white py-2 px-3 rounded-lg text-sm transition-colors">Stop</button>` :
                                    `<button onclick="startServer('${server._id}')" class="flex-1 bg-success-green hover:bg-green-600 text-white py-2 px-3 rounded-lg text-sm transition-colors">Start</button>`
                                }
                                <button onclick="restartServer('${server._id}')" class="bg-yellow-600 hover:bg-yellow-700 text-white py-2 px-3 rounded-lg text-sm transition-colors" ${server.status !== 'running' ? 'disabled class="opacity-50 cursor-not-allowed"' : ''}>Restart</button>
                            </div>
                        </div>

                        <!-- Player List -->
                        <div class="bg-dark-primary rounded-lg p-6 border border-gray-700">
                            <h4 class="text-lg font-semibold text-white mb-4">Players Online</h4>
                            <div class="space-y-2 max-h-48 overflow-y-auto custom-scrollbar">
                                ${server.players.list.length > 0 ?
                                    server.players.list.map(player => `
                                        <div class="flex items-center justify-between py-2 px-3 bg-dark-secondary rounded-lg">
                                            <span class="text-white">${player.name}</span>
                                            <span class="text-gray-400 text-sm">${Math.floor((Date.now() - new Date(player.joinedAt)) / 1000 / 60)}m</span>
                                        </div>
                                    `).join('') :
                                    '<p class="text-gray-400 text-center py-4">No players online</p>'
                                }
                            </div>
                        </div>
                    </div>

                    <!-- Console -->
                    <div class="lg:col-span-2">
                        <div class="bg-dark-primary rounded-lg border border-gray-700 h-96 flex flex-col">
                            <!-- Terminal Toolbar -->
                            <div class="terminal-toolbar">
                                <div class="terminal-dots">
                                    <div class="dot dot-red"></div>
                                    <div class="dot dot-yellow"></div>
                                    <div class="dot dot-green"></div>
                                </div>
                                <div class="terminal-title">Minecraft Server Console</div>
                            </div>

                            <!-- Terminal Content -->
                            <div id="console-output-${serverId}" class="flex-1 p-4 overflow-auto custom-scrollbar bg-black text-green-400 font-mono text-sm">
                                <!-- Console output will appear here -->
                            </div>

                            <!-- Console Input -->
                            <div class="border-t border-gray-700 p-4">
                                <div class="flex space-x-2">
                                    <span class="text-green-400 font-mono">$</span>
                                    <input type="text"
                                           id="console-command-${serverId}"
                                           placeholder="Enter command..."
                                           class="flex-1 bg-transparent text-green-400 font-mono border-none outline-none"
                                           onkeypress="handleConsoleKeypress(event, '${serverId}')">
                                    <button onclick="sendConsoleCommand('${serverId}')"
                                            class="bg-electric-purple hover:bg-purple-700 text-white px-3 py-1 rounded text-sm transition-colors">
                                        Send
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `;

            modal.classList.remove('hidden');

            // Join server room for real-time updates
            window.AuthUtils.socket.emit('join-server', serverId);

            // Initialize terminal (placeholder for xterm.js integration)
            initializeTerminal(serverId);
        }
    } catch (error) {
        console.error('View server details error:', error);
        showNotification('Failed to load server details', 'error');
    }
}

function initializeTerminal(serverId) {
    // Placeholder for xterm.js integration
    const consoleOutput = document.getElementById(`console-output-${serverId}`);
    if (consoleOutput) {
        consoleOutput.innerHTML = '<div class="text-green-400">Server console connected...</div>';
    }
}

function handleConsoleKeypress(event, serverId) {
    if (event.key === 'Enter') {
        sendConsoleCommand(serverId);
    }
}

async function sendConsoleCommand(serverId) {
    const commandInput = document.getElementById(`console-command-${serverId}`);
    const command = commandInput.value.trim();

    if (!command) return;

    try {
        // Add command to console
        const consoleOutput = document.getElementById(`console-output-${serverId}`);
        const commandLine = document.createElement('div');
        commandLine.innerHTML = `<span class="text-green-400">$ ${command}</span>`;
        consoleOutput.appendChild(commandLine);

        // Send command via API
        await window.AuthUtils.apiRequest(`/api/servers/${serverId}/console`, {
            method: 'POST',
            body: JSON.stringify({ command })
        });

        commandInput.value = '';

        // Scroll to bottom
        consoleOutput.scrollTop = consoleOutput.scrollHeight;

    } catch (error) {
        console.error('Send console command error:', error);
        showNotification('Failed to send command', 'error');
    }
}

async function deleteServer(serverId) {
    if (!confirm('Are you sure you want to delete this server? This action cannot be undone.')) {
        return;
    }

    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}`, {
            method: 'DELETE'
        });

        if (response.success) {
            loadServers();
            loadDashboardData();
            alert('Server deleted successfully!');
        } else {
            alert(response.message || 'Failed to delete server');
        }
    } catch (error) {
        console.error('Delete server error:', error);
        alert('Failed to delete server');
    }
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

// Socket.IO event listeners
window.AuthUtils.socket.on('console-output', (data) => {
    const consoleOutput = document.getElementById('console-output');
    if (consoleOutput) {
        const outputLine = document.createElement('div');
        outputLine.textContent = data;
        consoleOutput.appendChild(outputLine);
        consoleOutput.scrollTop = consoleOutput.scrollHeight;
    }
});

window.AuthUtils.socket.on('server-started', (data) => {
    showNotification(`Server ${data.serverId} started successfully!`, 'success');
    loadServers();
    loadDashboardData();
});

window.AuthUtils.socket.on('server-stopped', (data) => {
    showNotification(`Server ${data.serverId} stopped successfully!`, 'info');
    loadServers();
    loadDashboardData();
});