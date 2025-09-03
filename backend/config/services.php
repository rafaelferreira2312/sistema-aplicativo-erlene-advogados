<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this configuration.
    |
    */

    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
        'endpoint' => env('MAILGUN_ENDPOINT', 'api.mailgun.net'),
        'scheme' => 'https',
    ],

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    // Integração CNJ DataJud
    'cnj' => [
        'api_key' => env('CNJ_API_KEY'),
        'base_url' => env('CNJ_BASE_URL', 'https://api-publica.datajud.cnj.jus.br'),
        'timeout' => env('CNJ_TIMEOUT', 30),
        'enabled' => env('CNJ_ENABLED', false),
    ],

    // Outras integrações jurídicas
    'escavador' => [
        'api_key' => env('ESCAVADOR_API_KEY'),
        'base_url' => env('ESCAVADOR_BASE_URL', 'https://api.escavador.com'),
        'enabled' => env('ESCAVADOR_ENABLED', false),
    ],

    'jurisbrasil' => [
        'api_key' => env('JURISBRASIL_API_KEY'),
        'base_url' => env('JURISBRASIL_BASE_URL', 'https://api.jurisbrasil.com.br'),
        'enabled' => env('JURISBRASIL_ENABLED', false),
    ],

];
