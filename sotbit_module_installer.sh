#!/usr/bin/env bash

if ! command -v composer >/dev/null 2>&1; then
  echo "❌ Composer не найден! Установите Composer и добавьте его в PATH."
  exit 1
else
  echo "✅ Composer найден: $(composer --version)"
fi


echo "Введите название модуля (пример: vendor.module):"
read MODULE_NAME

if [ -z "$MODULE_NAME" ]; then
  echo "Название модуля не может быть пустым"
  exit 1
fi

BASE_DIR="$MODULE_NAME"

# Разделяем vendor и module
VENDOR=$(echo "$MODULE_NAME" | cut -d'.' -f1)
MODULE=$(echo "$MODULE_NAME" | cut -d'.' -f2)
VENDOR_UCFIRST=$(echo "$VENDOR" | sed -E 's/^(.)/\U\1/')
MODULE_UCFIRST=$(echo "$MODULE" | sed -E 's/^(.)/\U\1/')

if [ -z "$VENDOR" ] || [ -z "$MODULE" ]; then
  echo "Неверный формат названия модуля. Формат: vendor.module"
  exit 1
fi


#TODO Создаём структуру

#install dir
mkdir -p "$BASE_DIR/install/admin"
mkdir -p "$BASE_DIR/install/js/$MODULE/namespace"
mkdir -p "$BASE_DIR/install/themes/.default/icons/$VENDOR.$MODULE"
#lib dir
mkdir -p "$BASE_DIR/lib"
mkdir -p "$BASE_DIR/lib/Admin"
mkdir -p "$BASE_DIR/lib/Tables"
#lang dir
mkdir -p "$BASE_DIR/lang/ru/install"
mkdir -p "$BASE_DIR/lang/ru/lib"
mkdir -p "$BASE_DIR/lang/ru/admin"
#js dir
mkdir -p "$BASE_DIR/js"
#admin dir
mkdir -p "$BASE_DIR/admin"


#TODO Директория install ----------------------------------------------------------------------------------------------------

# Создаём install/version.php
cat > "$BASE_DIR/install/version.php" <<EOF
<?php
\$arModuleVersion = [
    'VERSION' => '1.0.0',
    'VERSION_DATE' => '$(date +"%Y-%m-%d %H:%M:%S")',
];
EOF

# Создаём install/index.php
cat > "$BASE_DIR/install/index.php" <<EOF
<?php

use Bitrix\Main\{
    Localization\Loc,
    Application,
    Loader,
    ModuleManager,
    EventManager
};

// use ${MODULE_UCFIRST}\Tables;

IncludeModuleLangFile(__FILE__);

class ${VENDOR}_${MODULE} extends CModule
{
    const MODULE_ID = '${VENDOR}.${MODULE}';

    var \$MODULE_ID = '${VENDOR}.${MODULE}';
    var \$MODULE_VERSION;
    var \$MODULE_VERSION_DATE;
    var \$MODULE_NAME;
    var \$MODULE_DESCRIPTION;
    var \$MODULE_CSS;
    var \$MODULE_GROUP_RIGHTS = "Y";

    public \$events;
    private \$tables;

    function __construct()
    {
        \$arModuleVersion = [];
        include(dirname(__FILE__).'/version.php');

        \$this->MODULE_ID = self::MODULE_ID;
        \$this->MODULE_VERSION = $arModuleVersion["VERSION"];
        \$this->MODULE_VERSION_DATE = $arModuleVersion["VERSION_DATE"];
        \$this->MODULE_NAME = Loc::getMessage("${MODULE}_module_name");
        \$this->MODULE_DESCRIPTION = Loc::getMessage("${MODULE}_module_desc");
        \$this->PARTNER_NAME = Loc::getMessage('${MODULE}_partner_name');
        \$this->PARTNER_URI = '/';

        \$this->events = [
          [
              "FROM_MODULE_ID" => 'main',
              "EVENT_TYPE" => 'OnBuildGlobalMenu',
              "CLASS" => '\\${MODULE_UCFIRST}\EventHandlers',
              "METHOD" => 'onBuildGlobalMenuHandler',
              "SORT" => 100
          ],
        ];

        /*Пример заполнения списка таблиц при установке модуля
        \$this->tables = [
                   Tables\TestTable::class
                ];
        */
    }

    public function DoInstall()
        {
            ModuleManager::registerModule(self::MODULE_ID);
            \$this->InstallDB();
            \$this->InstallFiles();
            \$this->InstallEvents();

            return true;
        }

    public function DoUninstall()
        {
            ModuleManager::unRegisterModule(self::MODULE_ID);
            \$this->UnInstallDB();
            \$this->UnInstallFiles();
            \$this->UnInstallEvents();

            return true;
        }

      public function InstallFiles()
      {
          // TODO admin page
          CopyDirFiles(\$_SERVER['DOCUMENT_ROOT'] . '/local/modules/' . self::MODULE_ID . '/install/admin',
              \$_SERVER['DOCUMENT_ROOT'] . '/bitrix/admin');

          // TODO js lib
          //CopyDirFiles(\$_SERVER["DOCUMENT_ROOT"] . "/local/modules/" . self::MODULE_ID . "/install/js/",
          //    \$_SERVER["DOCUMENT_ROOT"] . "/bitrix/js/", true, true);

          // TODO css lib
          //CopyDirFiles(\$_SERVER["DOCUMENT_ROOT"] . "/local/modules/" . self::MODULE_ID . "/install/css/",
          //    \$_SERVER["DOCUMENT_ROOT"] . "/bitrix/css/", true, true);

          // TODO themes lib
          CopyDirFiles(\$_SERVER["DOCUMENT_ROOT"] . "/local/modules/" . self::MODULE_ID . "/install/themes/",
              \$_SERVER["DOCUMENT_ROOT"] . "/bitrix/themes/", true, true);

          //TODO components
          if (is_dir(\$p = \$_SERVER['DOCUMENT_ROOT'] . '/local/modules/' . self::MODULE_ID . '/install/components/')) {
              if (\$dir = opendir(\$p)) {
                  while (false !== \$item = readdir(\$dir)) {
                      if (\$item == '..' || \$item == '.') {
                          continue;
                      }
                      CopyDirFiles(\$p . \$item, \$_SERVER['DOCUMENT_ROOT'] . '/local/components/' . \$item, \$ReWrite = True, \$Recursive = True);
                  }
                  closedir(\$dir);
              }
          }\

          return true;
      }

      public function UnInstallFiles()
      {
          // TODO js lib
            // DeleteDirFiles(\$_SERVER["DOCUMENT_ROOT"] . "/local/modules/" . self::MODULE_ID . "/install/js",
            //     \$_SERVER["DOCUMENT_ROOT"] . "/bitrix/js/", true, true);

          // TODO css lib
  //        DeleteDirFiles(\$_SERVER["DOCUMENT_ROOT"] . "/local/modules/" . self::MODULE_ID . "/install/css",
  //            \$_SERVER["DOCUMENT_ROOT"] . "/bitrix/css/", true, true);

          // TODO admin page
          DeleteDirFiles(\$_SERVER['DOCUMENT_ROOT'] . '/bitrix/modules/' . self::MODULE_ID . '/install/admin',
              \$_SERVER['DOCUMENT_ROOT'] . '/bitrix/admin');

          // TODO themes lib
          DeleteDirFiles(\$_SERVER["DOCUMENT_ROOT"] . "/local/modules/" . self::MODULE_ID . "/install/themes/.default/icons/",
              \$_SERVER["DOCUMENT_ROOT"] . "/bitrix/themes/.default/icons");

          //TODO components
          if (is_dir(\$p = \$_SERVER['DOCUMENT_ROOT'] . '/local/modules/' . self::MODULE_ID . '/install/components/\${MODULE}/')) {
              if (\$dir = opendir(\$p)) {
                  while (false !== \$item = readdir(\$dir)) {
                      if (\$item == '..' || \$item == '.' || !is_dir(\$p0 = \$p . \$item)) {
                          continue;
                      }
                      \$dir0 = opendir(\$p0);
                      while (false !== \$item0 = readdir(\$dir0)) {
                          if (\$item0 == '..' || \$item0 == '.') {
                              continue;
                          }
                          DeleteDirFilesEx('/bitrix/components/${MODULE}/' . \$item . '/' . \$item0);
                      }
                      closedir(\$dir0);
                  }
                  closedir(\$dir);
              }
          }

          return true;
      }

      public function InstallEvents()
      {
          foreach (\$this->events as \$event) {
              EventManager::getInstance()->registerEventHandler(
                  \$event['FROM_MODULE_ID'],
                  \$event['EVENT_TYPE'],
                  self::MODULE_ID,
                  \$event['CLASS'],
                  \$event['METHOD'],
                  \$event['SORT'] ?? 100
              );
          }

          return true;
      }

      public function UnInstallEvents()
      {
          foreach (\$this->events as \$event) {
              EventManager::getInstance()->unRegisterEventHandler(
                  \$event['FROM_MODULE_ID'],
                  \$event['EVENT_TYPE'],
                  self::MODULE_ID,
                  \$event['CLASS'],
                  \$event['METHOD'],
              );
          }

          return true;
      }

      public function InstallDB()
      {
          if (Loader::includeModule(self::MODULE_ID)) {
              \$connection = Application::getConnection();
              foreach (\$this->tables as \$class) {
                  \$classEntity = \$class::getEntity();
                  if (!\$connection->isTableExists(\$classEntity->getDBTableName())) {
                      \$classEntity->createDbTable();
                  }
              }
          }

          return true;
      }

      public function UnInstallDB()
      {
          if (Loader::includeModule(self::MODULE_ID)) {
              \$connection = Application::getConnection();

              foreach (\$this->tables as \$class) {
                  \$classEntity = \$class::getEntity();
                  if (\$connection->isTableExists(\$classEntity->getDBTableName())) {
                      \$connection->dropTable(\$classEntity->getDBTableName());
                  }
              }
          }

          return true;
      }
}
EOF

# Создаём install/admin/${VENDOR}.${MODULE}_settings.php
cat > "$BASE_DIR/install/admin/${VENDOR}.${MODULE}_settings.php" <<EOF
<?php
require(\$_SERVER['DOCUMENT_ROOT'].'/local/modules/${BASE_DIR}/admin/${VENDOR}.${MODULE}_settings.php');
EOF

# Создаём $BASE_DIR/install/js/$MODULE/namespace/config.php
cat > "$BASE_DIR/install/js/$MODULE/namespace/config.php" <<EOF
<?php

if (!defined("B_PROLOG_INCLUDED") || B_PROLOG_INCLUDED !== true) {
    die();
}

/* Создание конфига для js extentions модуля
return [
    'js' => [
        "/local/modules/${BASE_DIR}/js/namespace/index.js",
    ],
    "css" => [],
    'lang' => '',
    "rel" => [],
];
*/
EOF

# Создаём $BASE_DIR/install/themes/.default/${VENDOR}.${MODULE}.css
cat > "$BASE_DIR/install/themes/.default/${VENDOR}.${MODULE}.css" <<EOF
#global_menu_sotbit .adm-main-menu-item-icon{
    background: url("icons/sotbit/icon.png") no-repeat 50% 55%;
}

.${VENDOR}_${MODULE}_menu_icon{
    background: url("icons/${VENDOR}.${MODULE}/icon.png") no-repeat 50% 55%;
    background-size: contain;
}
EOF

#TODO Директория admin ------------------------------------------------------------------------------------------------------

# Создаём $BASE_DIR/admin/${VENDOR}.${MODULE}_settings.php
# Создаём $BASE_DIR/admin/${VENDOR}.${MODULE}_settings.php
cat > "$BASE_DIR/admin/${VENDOR}.${MODULE}_settings.php" <<EOF
<?php

use Bitrix\Main\{
    Localization\Loc
};

use ${MODULE_UCFIRST}\{
    Admin\Helper as AdminHelper,
    Config
};

require_once(\$_SERVER["DOCUMENT_ROOT"] . "/bitrix/modules/main/include/prolog_admin_before.php");

global \$APPLICATION;

IncludeModuleLangFile(__FILE__);

\$APPLICATION->setTitle(Loc::getMessage('sc_title'));

require_once(\$_SERVER['DOCUMENT_ROOT'] . '/bitrix/modules/main/include/prolog_admin.php');

\$siteId = Config::getDefaultSiteLid();

\$settingsValues = Config::getOptions();
\$request = \Bitrix\Main\Application::getInstance()->getContext()->getRequest();
\$requestValues = \$request->getValues();

if (\$request->isPost() && \$requestValues['save'] <> '') {
    Config::setOptions(\$requestValues['options'] ?? [], \$settingsValues);
}

\$arTabs = [
    [
        'DIV' => '${MODULE}_main',
        'TAB' => Loc::getMessage('sc_tab_settings'),
        'ICON' => '',
        'TITLE' => Loc::getMessage('sc_tab_settings'),
        'SORT' => ''
    ]
];

\$settingsForm = '${MODULE}_settings';

\$tabControl = new AdminHelper(\$settingsForm, \$arTabs);

\$tabControl->BeginEpilogContent();
echo bitrix_sessid_post();
\$tabControl->EndEpilogContent();
\$tabControl->Begin();

//TODO main settings tab
\$tabControl->BeginNextFormTab();

\$tabControl->arParams["FORM_ACTION"] = \$APPLICATION->GetCurPageParam();
\$arButtonsParams = [
    'disabled' => false,
    'btnApply' => false
];

\$tabControl->Buttons(\$arButtonsParams);

\$tabControl->SetShowSettings(false);
\$tabControl->Show();

require(\$_SERVER["DOCUMENT_ROOT"] . "/bitrix/modules/main/include/epilog_admin.php");
EOF

#Директория lib --------------------------------------------------------------------------------------------------------

# Создаём $BASE_DIR/lib/Admin/Helper.php
cat > "$BASE_DIR/lib/Admin/Helper.php" <<EOF
<?php

namespace ${MODULE_UCFIRST}\Admin;

class Helper extends \CAdminForm
{
    function AddDropDownMultiField(\$id, \$content, \$required, \$arSelect, array \$value = [], \$arParams = [])
    {
        if (empty(\$value)) {
            \$value = \$this->arFieldValues[\$id];
        }

        \$html = '<select name="' . \$id . '[]"';
        \$htmlHidden = '';

        \$html .= ' multiple="multiple"';

        foreach (\$arParams as \$param) {
            \$html .= ' ' . \$param;
        }

        \$html .= '>';

        foreach (\$arSelect as \$key => \$val) {
            \$html .= '<option value="' . htmlspecialcharsbx(\$key) . '"' . (is_array(\$value) && in_array(\$key, \$value) ? ' selected' : '') . '>' . htmlspecialcharsex(\$val) . '</option>';
            \$htmlHidden .= '<input type="hidden" name="' . \$id . '[]" value="' . htmlspecialcharsbx(\$value) . '">';
        }

        \$html .= '</select>';

        \$content = html_entity_decode(\$this->GetCustomLabelHTML(\$id, \$content));

        \$this->tabs[\$this->tabIndex]["FIELDS"][\$id] = [
            "id" => \$id,
            "required" => \$required,
            "content" => \$content,
            "html" => '<td width="40%">' . (\$required ? '<span class="adm-required-field">' . \$content . '</span>' : \$content) . '</td><td>' . \$html . '</td>',
            "hidden" => \$htmlHidden,
        ];
    }
}
EOF

# Создаём $BASE_DIR/lib/lib/Config.php
cat > "$BASE_DIR/lib/Config.php" <<EOF
<?php

namespace ${MODULE_UCFIRST};

use Bitrix\Main\{
    Config\Option,
    SiteTable
};

class Config
{
    public static function getDefaultSiteLid(): string
    {
        return SiteTable::getList([
            'filter' => ['DEF' => 'Y'],
            'select' => ['LID'],
            'limit' => 1
        ])->fetch()['LID'] ?? '';

    }

    public static function get(\$name, \$site = false): string|array
    {
        \$value = Option::get(\\${MODULE_UCFIRST}::MODULE_ID, \$name, "", \$site ?: \\${MODULE_UCFIRST}::SITE_ID_DEFAULT);

        if (self::is_serialized(\$value)) {
            \$value = unserialize(\$value, ['allowed_classes' => false]);
        }

        return \$value;
    }

    public static function set(\$name, \$value, \$site = false): void
    {

        if (is_array(\$value)) {
            \$value = serialize(\$value);
        }

        Option::set(\\${MODULE_UCFIRST}::MODULE_ID, \$name, \$value, \$site ?: \\${MODULE_UCFIRST}::SITE_ID_DEFAULT);
    }

    public static function getOptions(): array
    {
        \$arValues = Option::getForModule(\\${MODULE_UCFIRST}::MODULE_ID, \\${MODULE_UCFIRST}::SITE_ID_DEFAULT);

        foreach (\$arValues as &\$value) {
            if (self::is_serialized(\$value)) {
                \$value = unserialize(\$value, ['allowed_classes' => false]);
            }
        }

        return \$arValues ?? [];
    }

    public static function setOptions(array \$options, array &\$newSettings): void
    {
        if (empty(\$options)) {
            return;
        }

        foreach (\$options as \$key => \$value) {
            self::set(\$key, \$value);

            \$newSettings[\$key] = \$value;
        }
    }

    public static function is_serialized(\$data, \$strict = true)
    {
        // If it isn't a string, it isn't serialized.
        if (!is_string(\$data)) {
            return false;
        }
        \$data = trim(\$data);
        if ('N;' === \$data) {
            return true;
        }
        if (strlen(\$data) < 4) {
            return false;
        }
        if (':' !== \$data[1]) {
            return false;
        }
        if (\$strict) {
            \$lastc = substr(\$data, -1);
            if (';' !== \$lastc && '}' !== \$lastc) {
                return false;
            }
        } else {
            \$semicolon = strpos(\$data, ';');
            \$brace = strpos(\$data, '}');
            // Either ; or } must exist.
            if (false === \$semicolon && false === \$brace) {
                return false;
            }
            // But neither must be in the first X characters.
            if (false !== \$semicolon && \$semicolon < 3) {
                return false;
            }
            if (false !== \$brace && \$brace < 4) {
                return false;
            }
        }
        \$token = \$data[0];
        switch (\$token) {
            case 's':
                if (\$strict) {
                    if ('"' !== substr(\$data, -2, 1)) {
                        return false;
                    }
                } elseif (!str_contains(\$data, '"')) {
                    return false;
                }
            // Or else fall through.
            case 'a':
            case 'O':
            case 'E':
                return (bool)preg_match("/^{\$token}:[0-9]+:/s", \$data);
            case 'b':
            case 'i':
            case 'd':
                \$end = \$strict ? '\$' : '';
                return (bool)preg_match("/^{\$token}:[0-9.E+-]+;\$end/", \$data);
        }
        return false;
    }
\
    public static function getOptionEntity(string \$entity):array
    {
        \$options = self::getOptions();

        if(!empty(\$options[\$entity])) {
            return \$options[\$entity];
        }

        return [];
    }
}
EOF

# Создаём $BASE_DIR/lib/EventHandlers.php
cat > "$BASE_DIR/lib/EventHandlers.php" <<EOF
<?php

namespace ${MODULE_UCFIRST};

use Bitrix\Main\{
    Localization\Loc,
    Loader
};

class EventHandlers
{
    public static function onBuildGlobalMenuHandler(&\$arGlobalMenu, &\$arModuleMenu)
    {
        \$moduleInclude = Loader::includeModule('${VENDOR}.${MODULE}');

        if (!isset(\$arGlobalMenu['global_menu_sotbit'])) {
            \$arGlobalMenu['global_menu_sotbit'] = [
                'menu_id' => 'sotbit',
                'text' => Loc::getMessage('${MODULE}_global_menu'),
                'title' => Loc::getMessage('${MODULE}_global_menu'),
                'sort' => 1000,
                'items_id' => 'global_menu_sotbit_items',
                "icon" => "",
                "page_icon" => "",
            ];
        }

        \$menu = [];

        if (\$moduleInclude) {

            \$menu = [
                "section" => "${VENDOR}_${MODULE}",
                "menu_id" => "${VENDOR}_${MODULE}",
                "sort" => 1000,
                'id' => '${MODULE}',
                "text" => Loc::getMessage('${MODULE}_global_menu_module_name'),
                "title" => Loc::getMessage('${MODULE}_global_menu_module_name'),
                "icon" => "${VENDOR}_${MODULE}_menu_icon",
                "page_icon" => "",
                "items_id" => "global_menu_${VENDOR}_${MODULE}",
                "items" => [
                    [
                        'text' => Loc::getMessage('${MODULE}_settings'),
                        'title' => Loc::getMessage('${MODULE}_settings'),
                        'sort' => 10,
                        'icon' => 'sys_menu_icon',
                        'page_icon' => '',
                        "url" => '/bitrix/admin/${VENDOR}.${MODULE}_settings.php?lang=' . LANGUAGE_ID,
                    ],
                ],
                "more_url" => [],
            ];
        }

        \$arGlobalMenu['global_menu_sotbit']['items']['${VENDOR}.${MODULE}'] = \$menu;
    }
}
EOF

#TODO Директория $BASE_DIR --------------------------------------------------------------------------------------------------

#Создаём $BASE_DIR/include.php
cat > "$BASE_DIR/include.php" <<EOF
<?php
if (file_exists(\$_SERVER['DOCUMENT_ROOT'] . '/local/modules/${VENDOR}.${MODULE}/vendor/autoload.php')) {
    require_once \$_SERVER['DOCUMENT_ROOT'] . '/local/modules/${VENDOR}.${MODULE}/vendor/autoload.php';
}

class ${MODULE_UCFIRST}
{
    const MODULE_ID = '${VENDOR}.${MODULE}';
    const SITE_ID_DEFAULT = 's1';
}
EOF

#Создаём $BASE_DIR/.settings.php
cat > "$BASE_DIR/.settings.php" <<EOF
<?php
/*
Пример создания настроек контроллеров модуля

return [
    'controllers' => [
        'value' => [
            'namespaces' => [
                '\\\\${MODULE_UCFIRST}\\\\Main\\\\Test' => 'test',
            ],
        ],
        'defaultNamespace' => '\\\\${MODULE_UCFIRST}',
        'readonly' => true,
    ]
];
*/
EOF

#TODO Директория lang -------------------------------------------------------------------------------------------------------

#Создаём $BASE_DIR/lang/ru/install/index.php
cat > "$BASE_DIR/lang/ru/install/index.php" <<EOF
<?php
\$MESS['${MODULE}_module_name'] = '${MODULE}';
\$MESS['${MODULE}_module_desc'] = 'Модуль содержит доработки сайта';
\$MESS['${MODULE}_partner_name'] = 'Сотбит ОВ';
EOF

#Создаём $BASE_DIR/lang/ru/admin/${VENDOR}.${MODULE}_settings.php
cat > "$BASE_DIR/lang/ru/admin/${VENDOR}.${MODULE}_settings.php" <<EOF
<?php
\$MESS['sc_title'] = 'Основные настройки: ${MODULE_UCFIRST}';
\$MESS['sc_tab_settings'] = 'Настройки';
EOF

#Создаём $BASE_DIR/lang/ru/lib/EventHandlers.php
cat > "$BASE_DIR/lang/ru/lib/EventHandlers.php" <<EOF
<?php
\$MESS['${MODULE}_global_menu'] = '${VENDOR_UCFIRST}';
\$MESS['${MODULE}_global_menu_module_name'] = '${VENDOR_UCFIRST}: ${MODULE_UCFIRST}';

\$MESS['${MODULE}_settings'] = 'Общие настройки';
EOF

echo "Структура модуля создана в ${BASE_DIR}"

#TODO установка composer в модуль
echo "Выполняется авто-инициализация composer..."

cat > "$BASE_DIR/composer.json" <<EOF
{
    "name": "${VENDOR}/${MODULE}",
    "description": "Bitrix module ${VENDOR}.${MODULE}",
    "type": "project",
    "license": "proprietary",
    "autoload": {
        "psr-4": {
            "${MODULE_UCFIRST}\\\\": "lib/"
        }
    },
    "require": {
            "php": ">=8.1"
        },
        "config": {
            "platform": {
                "php": "8.1"
            }
        }
}
EOF

cd "$BASE_DIR"
composer install
echo "Установка composer завершена"
