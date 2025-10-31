# 存放证书

## 生成自签名证书

```shell
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 3650 -nodes
```

> 参数说明
> -x509 生成自签名证书
> -newkey rsa:2048 生成新的 RSA 2048 位密钥
> -keyout 私钥输出文件
> -out 证书输出文件
> -days 3650 证书有效期（天）
> -nodes 不加密私钥

## 证书命名规范

以`.crt`结尾即可

```shell
cp cert.pem server.crt
```
