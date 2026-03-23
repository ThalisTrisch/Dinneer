// Tipos compartilhados da aplicação

export interface ApiResponse<T = any> {
  operacao: string;
  NumMens: number;
  Mensagem: string;
  registros: number;
  dados: T;
}

export interface DatabaseConfig {
  host: string;
  port: number;
  user: string;
  password: string;
  database: string;
}

export interface Usuario {
  id_usuario: number;
  nu_cpf: string;
  nm_usuario: string;
  nm_sobrenome: string;
  vl_email: string;
  vl_senha?: string;
  vl_foto?: string | null;
  fl_anfitriao?: string;
}

export interface LoginData {
  vl_email: string;
  vl_senha: string;
}

export interface CreateUsuarioData {
  nu_cpf: string;
  nm_usuario: string;
  nm_sobrenome: string;
  vl_email: string;
  vl_senha: string;
  vl_foto?: string | null;
}
