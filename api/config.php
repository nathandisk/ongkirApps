<?php
    // Replace 'YOUR_API_KEY' with your actual RajaOngkir API key
    $apiKey = '2c88e5b7eead16fe715ad190cb09bcdb';
    
    // Handle only POST requests
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Fetch POST data and validate inputs
        $courier = $_POST['courier'] ?? '';
        $origin = $_POST['origin'] ?? '';
        $destination = $_POST['destination'] ?? '';
        $weight = $_POST['weight'] ?? '';
    
        // Ensure all required fields are provided
        if (empty($courier) || empty($origin) || empty($destination) || empty($weight)) {
            header('Content-Type: application/json');
            echo json_encode(['error' => 'All fields (courier, origin, destination, weight) are required.']);
            exit;
        }
    
        // Construct the API request
        $url = "https://api.rajaongkir.com/starter/cost";
        $postData = http_build_query([
            'origin' => $origin,
            'originType' => 'city',
            'destination' => $destination,
            'destinationType' => 'subdistrict',
            'weight' => $weight,
            'courier' => $courier
        ]);
    
        // Initialize cURL
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            "Content-Type: application/x-www-form-urlencoded",
            "key: $apiKey"
        ]);
    
        // Execute the request
        $response = curl_exec($ch);
    
        if (curl_errno($ch)) {
            // Handle cURL error
            $error_message = curl_error($ch);
            curl_close($ch);
            header('Content-Type: application/json');
            echo json_encode(['error' => $error_message]);
            exit;
        }
    
        curl_close($ch);
    
        // Validate and send the API response back to the client
        $decodedResponse = json_decode($response, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            header('Content-Type: application/json');
            echo json_encode(['error' => 'Invalid JSON response from API.']);
            exit;
        }
    
        header('Content-Type: application/json');
        echo $response;
        exit;
    } else {
        // Handle invalid request method
        header('Content-Type: application/json');
        echo json_encode(['error' => 'Invalid request method. Only POST is allowed.']);
        exit;
    }
?>
