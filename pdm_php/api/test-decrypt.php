<?php
$senhaDoBanco = 'laAHE/WEvJhr5v55nl4sPA==';
$metodo_criptografia = 'aes-256-cbc';
$chave = 'sua_chave_secreta_de_32_bytes';
$iv = '1234567891234567';

echo "=================================\n";
echo "Teste de Descriptografia PHP\n";
echo "=================================\n";
echo "Senha criptografada do banco: $senhaDoBanco\n";
echo "\n";

$senhaDescriptografada = openssl_decrypt($senhaDoBanco, $metodo_criptografia, $chave, 0, $iv);
echo "Senha descriptografada: $senhaDescriptografada\n";
echo "=================================\n";
?>
