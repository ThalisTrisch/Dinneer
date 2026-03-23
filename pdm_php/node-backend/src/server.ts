import { App } from './app';
import { config } from './config/environment';

/**
 * Inicializa o servidor
 */
const app = new App().app;
const PORT = config.server.port;

app.listen(PORT, () => {
  console.log('=================================');
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`📍 http://localhost:${PORT}`);
  console.log('=================================');
  console.log('Endpoints disponíveis:');
  console.log(`  GET/POST http://localhost:${PORT}/api/v1/usuario/UsuarioController?operacao=loginUsuario`);
  console.log(`  GET      http://localhost:${PORT}/api/v1/usuario/UsuarioController?operacao=getUsuarios`);
  console.log('=================================');
});
