// Admin panel functionality
document.addEventListener('DOMContentLoaded', function() {
    if (!window.AuthUtils.checkAuth()) return;

    const user = window.AuthUtils.getUser();
    if (user.role !== 'admin') {
        window.location.href = '/dashboard';
        return;
    }

    // Logout functionality
    document.getElementById('logoutBtn').addEventListener('click', () => {
        window.AuthUtils.logout();
    });

    // Tab switching
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.admin-tab-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const tabName = button.getAttribute('data-tab');

            // Remove active class from all tabs
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));

            // Add active class to clicked tab
            button.classList.add('active');
            document.getElementById(tabName + 'Tab').classList.add('active');
        });
    });

    // Load admin data
    loadAdminStats();
    loadUsers();
    loadServers();
    loadNodes();

    // Modal controls
    const addUserModal = document.getElementById('addUserModal');
    const addNodeModal = document.getElementById('addNodeModal');
    const closeButtons = document.querySelectorAll('.close');

    document.getElementById('addUserBtn').addEventListener('click', () => {
        addUserModal.style.display = 'block';
    });

    document.getElementById('addNodeBtn').addEventListener('click', () => {
        addNodeModal.style.display = 'block';
    });

    closeButtons.forEach(button => {
        button.addEventListener('click', () => {
            addUserModal.style.display = 'none';
            addNodeModal.style.display = 'none';
        });
    });

    // Close modal when clicking outside
    window.addEventListener('click', (event) => {
        if (event.target === addUserModal) {
            addUserModal.style.display = 'none';
        }
        if (event.target === addNodeModal) {
            addNodeModal.style.display = 'none';
        }
    });

    // Add user form
    document.getElementById('addUserForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = {
            username: document.getElementById('userUsername').value,
            email: document.getElementById('userEmail').value,
            password: document.getElementById('userPassword').value,
            role: document.getElementById('userRole').value
        };

        try {
            const response = await window.AuthUtils.apiRequest('/api/admin/users', {
                method: 'POST',
                body: JSON.stringify(formData)
            });

            if (response.success) {
                addUserModal.style.display = 'none';
                document.getElementById('addUserForm').reset();
                loadUsers();
                loadAdminStats();
                alert('User created successfully!');
            } else {
                alert(response.message || 'Failed to create user');
            }
        } catch (error) {
            console.error('Create user error:', error);
            alert('Failed to create user. Please try again.');
        }
    });

    // Add node form
    document.getElementById('addNodeForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        const formData = {
            name: document.getElementById('nodeName').value,
            host: document.getElementById('nodeHost').value,
            port: document.getElementById('nodePort').value,
            username: document.getElementById('nodeUsername').value,
            password: document.getElementById('nodePassword').value,
            location: document.getElementById('nodeLocation').value,
            maxMemory: document.getElementById('nodeMaxMemory').value,
            maxDisk: document.getElementById('nodeMaxDisk').value,
            maxServers: document.getElementById('nodeMaxServers').value
        };

        try {
            const response = await window.AuthUtils.apiRequest('/api/nodes', {
                method: 'POST',
                body: JSON.stringify(formData)
            });

            if (response.success) {
                addNodeModal.style.display = 'none';
                document.getElementById('addNodeForm').reset();
                loadNodes();
                loadAdminStats();
                alert('Node created successfully!');
            } else {
                alert(response.message || 'Failed to create node');
            }
        } catch (error) {
            console.error('Create node error:', error);
            alert('Failed to create node. Please try again.');
        }
    });
});

async function loadAdminStats() {
    try {
        const response = await window.AuthUtils.apiRequest('/api/admin/stats');

        if (response.success) {
            const stats = response.stats;
            document.getElementById('totalUsers').textContent = stats.totalUsers;
            document.getElementById('totalServers').textContent = stats.totalServers;
            document.getElementById('totalNodes').textContent = stats.totalNodes;
            document.getElementById('memoryUsage').textContent = `${stats.memoryUsage.percentage}%`;
        }
    } catch (error) {
        console.error('Load admin stats error:', error);
    }
}

async function loadUsers() {
    try {
        const response = await window.AuthUtils.apiRequest('/api/admin/users');

        if (response.success) {
            const usersTableBody = document.getElementById('usersTableBody');
            usersTableBody.innerHTML = '';

            response.users.forEach(user => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${user.username}</td>
                    <td>${user.email}</td>
                    <td>${user.role}</td>
                    <td><span class="status-${user.isActive ? 'online' : 'offline'}">${user.isActive ? 'Active' : 'Inactive'}</span></td>
                    <td>${new Date(user.createdAt).toLocaleDateString()}</td>
                    <td class="actions-column">
                        <button class="btn btn-sm btn-secondary" onclick="editUser('${user._id}')">Edit</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteUser('${user._id}')">Delete</button>
                    </td>
                `;
                usersTableBody.appendChild(row);
            });
        }
    } catch (error) {
        console.error('Load users error:', error);
    }
}

async function loadServers() {
    try {
        const response = await window.AuthUtils.apiRequest('/api/admin/servers');

        if (response.success) {
            const serversTableBody = document.getElementById('serversTableBody');
            serversTableBody.innerHTML = '';

            response.servers.forEach(server => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${server.name}</td>
                    <td>${server.owner.username}</td>
                    <td>${server.node.name}</td>
                    <td><span class="status-${server.status}">${server.status}</span></td>
                    <td>${server.players.online}/${server.players.max}</td>
                    <td>${server.version}</td>
                    <td class="actions-column">
                        <button class="btn btn-sm btn-secondary" onclick="viewServer('${server._id}')">View</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteServerAdmin('${server._id}')">Delete</button>
                    </td>
                `;
                serversTableBody.appendChild(row);
            });
        }
    } catch (error) {
        console.error('Load servers error:', error);
    }
}

async function loadNodes() {
    try {
        const response = await window.AuthUtils.apiRequest('/api/nodes');

        if (response.success) {
            const nodesTableBody = document.getElementById('nodesTableBody');
            nodesTableBody.innerHTML = '';

            response.nodes.forEach(node => {
                const memoryPercent = Math.round((node.usedMemory / node.maxMemory) * 100);
                const diskPercent = Math.round((node.usedDisk / node.maxDisk) * 100);

                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${node.name}</td>
                    <td>${node.host}:${node.port}</td>
                    <td><span class="status-${node.status}">${node.status}</span></td>
                    <td>${node.usedMemory}MB / ${node.maxMemory}MB (${memoryPercent}%)</td>
                    <td>${node.usedDisk}MB / ${node.maxDisk}MB (${diskPercent}%)</td>
                    <td>${node.serverCount} / ${node.maxServers}</td>
                    <td class="actions-column">
                        <button class="btn btn-sm btn-secondary" onclick="pingNode('${node._id}')">Ping</button>
                        <button class="btn btn-sm btn-secondary" onclick="editNode('${node._id}')">Edit</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteNode('${node._id}')">Delete</button>
                    </td>
                `;
                nodesTableBody.appendChild(row);
            });
        }
    } catch (error) {
        console.error('Load nodes error:', error);
    }
}

async function editUser(userId) {
    // Implement user editing functionality
    alert('User editing functionality will be implemented');
}

async function deleteUser(userId) {
    if (!confirm('Are you sure you want to delete this user?')) {
        return;
    }

    try {
        const response = await window.AuthUtils.apiRequest(`/api/admin/users/${userId}`, {
            method: 'DELETE'
        });

        if (response.success) {
            loadUsers();
            loadAdminStats();
            alert('User deleted successfully!');
        } else {
            alert(response.message || 'Failed to delete user');
        }
    } catch (error) {
        console.error('Delete user error:', error);
        alert('Failed to delete user');
    }
}

async function viewServer(serverId) {
    // Redirect to server details (could open modal or redirect)
    window.open(`/dashboard#server-${serverId}`, '_blank');
}

async function deleteServerAdmin(serverId) {
    if (!confirm('Are you sure you want to delete this server? This action cannot be undone.')) {
        return;
    }

    try {
        const response = await window.AuthUtils.apiRequest(`/api/servers/${serverId}`, {
            method: 'DELETE'
        });

        if (response.success) {
            loadServers();
            loadAdminStats();
            alert('Server deleted successfully!');
        } else {
            alert(response.message || 'Failed to delete server');
        }
    } catch (error) {
        console.error('Delete server error:', error);
        alert('Failed to delete server');
    }
}

async function pingNode(nodeId) {
    try {
        const response = await window.AuthUtils.apiRequest(`/api/nodes/${nodeId}/ping`);

        if (response.success) {
            loadNodes();
            alert(`Node is ${response.online ? 'online' : 'offline'}`);
        } else {
            alert('Failed to ping node');
        }
    } catch (error) {
        console.error('Ping node error:', error);
        alert('Failed to ping node');
    }
}

async function editNode(nodeId) {
    // Implement node editing functionality
    alert('Node editing functionality will be implemented');
}

async function deleteNode(nodeId) {
    if (!confirm('Are you sure you want to delete this node? This will affect all servers on this node.')) {
        return;
    }

    try {
        const response = await window.AuthUtils.apiRequest(`/api/nodes/${nodeId}`, {
            method: 'DELETE'
        });

        if (response.success) {
            loadNodes();
            loadAdminStats();
            alert('Node deleted successfully!');
        } else {
            alert(response.message || 'Failed to delete node');
        }
    } catch (error) {
        console.error('Delete node error:', error);
        alert('Failed to delete node');
    }
}