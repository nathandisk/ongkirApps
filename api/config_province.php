<?php
function fetchProvinces() {
    $apiKey = '2c88e5b7eead16fe715ad190cb09bcdb';
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, "https://api.rajaongkir.com/starter/province");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "key: $apiKey"
    ]);
    
    $response = curl_exec($ch);
    
    if (curl_errno($ch)) {
        $error_message = curl_error($ch);
        curl_close($ch);
        echo json_encode(['error' => $error_message]);
        exit;
    }

    curl_close($ch);
    
    $decodedResponse = json_decode($response, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo json_encode(['error' => 'Invalid JSON response']);
        exit;
    }

    echo json_encode($decodedResponse['rajaongkir']['results']);
    exit;
}

fetchProvinces();
?>