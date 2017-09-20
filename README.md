# README #

## Pre

Установите docker, docker-compose


## Установка

> git clone https://github.com/antirek/lua-dialplan-masterclass

> cd lua-dialplan-masterclass 

> docker-compose up


## Описание

Запускаются 4 сервиса: asterisk, mongodb, redis, manager (веб-сервер на nodejs)

В ./dockerfiles описаны dockerfile для asterisk, manager

В ./store описаны конфигурации для сервисов

В ./store/asterisk/etc/ находится конфигурация для asterisk 

./hosts скопировать в hosts рабочей машины


### lua-диалплан

В ./store/asterisk/etc/asterisk/dialplan находится пример диалплана на lua

Пример содержит функции-обработчики для 

- обычного звонка

- звонка с запросом в mongodb

- звонка с http-запросом к manager

- звонка с использованием redis


