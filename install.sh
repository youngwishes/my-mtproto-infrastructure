#!/bin/sh

# Переменные с значениями по умолчанию
DOMAIN="${DOMAIN:-free.beatvault.ru}"
EMAIL="${EMAIL:-mysc1@yandex.ru}"
CERTBOT_PATH="${CERTBOT_PATH:-$(pwd)/certbot}"

# Проверка обязательных переменных
if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Ошибка: DOMAIN и EMAIL должны быть заданы"
    echo "Использование: DOMAIN=example.com EMAIL=user@example.com $0"
    exit 1
fi

echo "Настройка SSL для домена: ${DOMAIN}"
echo "Email для уведомлений: ${EMAIL}"
echo "Путь для сертификатов: ${CERTBOT_PATH}"

# 1. Установка Docker
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# 2. Добавляем ключ и репозиторий
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Обновляем индекс и ставим Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Запуск Certbot
docker run -it --rm \
  -v "${CERTBOT_PATH}/conf:/etc/letsencrypt" \
  -v "${CERTBOT_PATH}/www:/var/www/certbot" \
  -p 80:80 \
  certbot/certbot certonly --standalone \
  -d ${DOMAIN} \
  --email ${EMAIL} \
  --agree-tos \
  --non-interactive

if [ $? -eq 0 ]; then
    echo "✅ SSL-сертификат успешно получен для ${DOMAIN}"
else
    echo "❌ Ошибка при получении SSL-сертификата"
    exit 1
fi