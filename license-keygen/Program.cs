using System.Security.Cryptography;

var dir = @"D:\Atlas\license-keys\mkerp";
Directory.CreateDirectory(dir);
using var rsa = RSA.Create(3072);
File.WriteAllText(Path.Combine(dir, "private-key.pem"), rsa.ExportPkcs8PrivateKeyPem());
File.WriteAllText(Path.Combine(dir, "public-key.pem"), rsa.ExportSubjectPublicKeyInfoPem());
Console.WriteLine("KEYPAIR_CREATED");