// Start the Minecraft Ultra Controller
const { start } = require('./controller/fastify-controller');

start().catch(console.error);