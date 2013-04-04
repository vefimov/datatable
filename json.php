<?php
    header('Content-Type: application/json');
    $data = array();
    for($i=0; $i < 200; $i++){
        $data[] = array(
            "id"            => $i,
            "hidden"        => $i,
            "first_name"    => "First Name {$i}",
            "last_name"     => "Last Name {$i}"
        );
    }
    echo json_encode(array(
        "records" => $data,
        "totalRecords" => 200
    ));