/// MedicineModel.dart
import 'dart:convert';

Medicine medicineFromJson(String str) {
    final jsonData = json.decode(str);
    return Medicine.fromJson(jsonData);
}

String medicineToJson(Medicine data) {
    final dyn = data.toJson();
    return json.encode(dyn);
}

class Medicine{
    int id;
    String name;
    String interval;

    Medicine({
        this.id,
        this.name,
        this.interval,
    });

    factory Medicine.fromJson(Map<String, dynamic> json) => new Medicine(
        id: json["id"],
        name: json["name"],
        interval: json["interval"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "interval": interval,
    };
}