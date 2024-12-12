<?php
function fetchCities($provinceId) {
    $apiKey = '2c88e5b7eead16fe715ad190cb09bcdb';
    
    // Build the URL with the province_id query parameter
    $url = "https://api.rajaongkir.com/starter/city?province=$provinceId";
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
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
    
    if (isset($decodedResponse['rajaongkir']['results'])) {
        echo json_encode($decodedResponse['rajaongkir']['results']);
    } else {
        echo json_encode(['error' => 'No results found']);
    }
    exit;
}

// Check for province_id in the request
if (isset($_GET['province_id'])) {
    $provinceId = intval($_GET['province_id']); // Sanitize input
    fetchCities($provinceId);
} else {
    echo json_encode(['error' => 'province_id parameter is required']);
    exit;
}
?>
