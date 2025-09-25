# Sotbit Module Installer

Скрипт автоматизирует создание структуры модуля для **1C-Bitrix**.  
Он генерирует директории, необходимые файлы (`install`, `lib`, `lang`, `admin` и др.), а также выполняет инициализацию **Composer**.

---

## 🚀 Возможности

- Создание стандартной структуры Bitrix-модуля
- Генерация:
  - `install/version.php`
  - `install/index.php` с классом модуля
  - `include.php`
  - `lib/Config.php`, `lib/EventHandlers.php`, `lib/Admin/Helper.php`
  - языковых файлов (`lang/ru/...`)
  - админских страниц
- Поддержка автозагрузки через **Composer**
- Настройка меню в админке Bitrix

---

## 📂 Структура модуля

Пример структуры, создаваемой скриптом:

```
vendor.module/
├── admin/
│   └── vendor.module_settings.php
├── install/
│   ├── admin/
│   ├── js/
│   ├── themes/
│   ├── version.php
│   └── index.php
├── js/
├── lang/
│   └── ru/
│       ├── admin/
│       ├── install/
│       └── lib/
├── lib/
│   ├── Admin/
│   │   └── Helper.php
│   ├── Tables/
│   ├── Config.php
│   └── EventHandlers.php
├── include.php
├── .settings.php
└── composer.json
```

---

## ⚙️ Установка и запуск

1. Разместите скрипт в папке, где будет лежать модуль

2. Запустите:

   ```bash
   ./sotbit_module_installer.sh
   ```

3. Введите название модуля в формате:

   ```
   vendor.module
   ```

   > Пример: `sotbit.loyalty`

4. Скрипт создаст папку `vendor.module/` со структурой модуля и выполнит установку зависимостей через **Composer**.

---

## 📌 Требования

- PHP **>= 8.1**
- [Composer](https://getcomposer.org/) должен быть установлен и доступен в `$PATH`
- Доступ на запись в директорию, где запускается скрипт

---

## 🛠️ Настройка

После генерации модуля можно:
- Дополнить список таблиц в `install/index.php` и `lib/Tables/`
- Добавить свои JS/CSS-библиотеки и иконки в `install/js/` и `install/themes/`
- Изменить конфигурацию в `lib/Config.php`

---

## 📖 Пример

```bash
$ ./sotbit_module_installer.sh
Введите название модуля (пример: vendor.module):
sotbit.test
✅ Версия composer:: Composer version 2.7.2
Инициализация composer завершена
Структура модуля создана в sotbit.test
```

---

## 🧑‍💻 Автор

**Sotbit** – автоматизация разработки для Bitrix.
