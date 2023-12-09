# WebStack Laravel Rev Docker

## 简介

- 本镜像使用sqlite作为数据库，方便备份和迁移， sqlite数据和上传的图片放在data目录，只需备份这个目录即可。
- [原项目](https://github.com/uvham521/WebStack-Laravel) 已经 public achive，最后版本是1.2.6，相关的docker项目也停在1.2.2版本。为了满足本人需要和学习，我重新fork了原项目进行二次开发。
- 升级部分组件，如 `laravel admin` 至最新版本。


## 构建镜像和容器的相关命令

``` bash
docker build -t falconchen/webstack-rev .
docker compose exec -it wsl /bin/sh
docker compose logs
```
