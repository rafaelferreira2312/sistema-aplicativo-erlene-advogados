<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
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

    /*
    |--------------------------------------------------------------------------
    | Payment Services
    |--------------------------------------------------------------------------
    */

    'stripe' => [
        'public_key' => env('STRIPE_PUBLIC_KEY'),
        'secret' => env('STRIPE_SECRET_KEY'),
        'webhook_secret' => env('STRIPE_WEBHOOK_SECRET'),
        'currency' => env('STRIPE_CURRENCY', 'brl'),
    ],

    'mercadopago' => [
        'public_key' => env('MERCADOPAGO_PUBLIC_KEY'),
        'access_token' => env('MERCADOPAGO_ACCESS_TOKEN'),
        'webhook_secret' => env('MERCADOPAGO_WEBHOOK_SECRET'),
        'sandbox' => env('MERCADOPAGO_SANDBOX', true),
    ],

    /*
    |--------------------------------------------------------------------------
    | Google Services
    |--------------------------------------------------------------------------
    */

    'google' => [
        'client_id' => env('GOOGLE_CLIENT_ID'),
        'client_secret' => env('GOOGLE_CLIENT_SECRET'),
        'redirect' => env('GOOGLE_REDIRECT_URL'),
        'drive_folder_id' => env('GOOGLE_DRIVE_FOLDER_ID'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Microsoft Services
    |--------------------------------------------------------------------------
    */

    'microsoft' => [
        'client_id' => env('MICROSOFT_CLIENT_ID'),
        'client_secret' => env('MICROSOFT_CLIENT_SECRET'),
        'tenant_id' => env('MICROSOFT_TENANT_ID'),
        'redirect' => env('MICROSOFT_REDIRECT_URL'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Legal APIs
    |--------------------------------------------------------------------------
    */

    'cnj' => [
        'api_key' => env('CNJ_API_KEY'),
        'base_url' => env('CNJ_BASE_URL', 'https://api.cnj.jus.br'),
        'timeout' => 30,
    ],

    'escavador' => [
        'api_key' => env('ESCAVADOR_API_KEY'),
        'base_url' => env('ESCAVADOR_BASE_URL', 'https://api.escavador.com'),
        'timeout' => 30,
    ],

    'jurisbrasil' => [
        'api_key' => env('JURISBRASIL_API_KEY'),
        'base_url' => env('JURISBRASIL_BASE_URL', 'https://api.jurisbrasil.com.br'),
        'timeout' => 30,
    ],

];
