import crypto from 'crypto';

// Mesmos parâmetros do PHP
const key = 'sua_chave_secreta_de_32_bytes';
const iv = '1234567891234567';
const senha = '123456';

// Garante que a chave tenha exatamente 32 bytes
const keyBuffer = Buffer.alloc(32);
Buffer.from(key).copy(keyBuffer);

console.log('=================================');
console.log('Teste de Criptografia');
console.log('=================================');
console.log('Senha original:', senha);
console.log('Key length:', keyBuffer.length);
console.log('IV length:', Buffer.from(iv).length);
console.log('');

// Criptografa
const cipher = crypto.createCipheriv('aes-256-cbc', keyBuffer, Buffer.from(iv));
let encrypted = cipher.update(senha, 'utf8', 'base64');
encrypted += cipher.final('base64');

console.log('Senha criptografada (Node.js):', encrypted);
console.log('');

// Senha do banco (PHP)
const senhaDoBanco = 'laAHE/WEvJhr5v55nl4sPA==';
console.log('Senha do banco (PHP):', senhaDoBanco);
console.log('');

// Compara
console.log('São iguais?', encrypted === senhaDoBanco);
console.log('=================================');
