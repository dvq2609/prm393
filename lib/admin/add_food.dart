import 'package:flutter/material.dart';
import 'package:prm393/services/database.dart';
import 'package:prm393/widget/widget_support.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> fooditems = ['Ice-cream', 'Burger', 'Salad', 'Pizza'];
  // Hardcoded predefined asset images based on typical names
  final List<String> assetImages = [
    'images/salad2.png',
    'images/burger.png',
    'images/pizza.png',
    'images/salad.png',
  ];
  String? value;
  String? selectedAssetImage;
  TextEditingController namecontroller = new TextEditingController();
  TextEditingController pricecontroller = new TextEditingController();
  TextEditingController detailcontroller = new TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    var image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30, // Compress image quality to 30% for JPG
      maxWidth: 300, // Strictly resize image to max 300px width for all formats
      maxHeight: 300, // Strictly resize image to max 300px height for all formats
    );

    if (image != null) {
      selectedImage = File(image.path);
      selectedAssetImage = null; // Clear asset if gallery is used
      setState(() {});
    }
  }

  void selectAssetImage(String assetPath) {
    setState(() {
      selectedAssetImage = assetPath;
      selectedImage = null; // Clear gallery if asset is used
    });
  }

  uploadItem() async {
    if ((selectedImage != null || selectedAssetImage != null) &&
        namecontroller.text != "" &&
        pricecontroller.text != "" &&
        detailcontroller.text != "" &&
        value != null) {
      String downloadUrl = "";

      if (selectedImage != null) {
        // Encode the image to Base64 to save directly in Firestore
        List<int> imageBytes = await selectedImage!.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        // Prefix it so the UI knows it's a base64 string
        downloadUrl = "base64,$base64Image";
      } else if (selectedAssetImage != null) {
        // Use local asset path string for the image (you can handle this on display side if it starts with 'images/')
        downloadUrl = selectedAssetImage!;
      }

      Map<String, dynamic> addItem = {
        "Image": downloadUrl,
        "Name": namecontroller.text,
        "Price": pricecontroller.text,
        "Detail": detailcontroller.text,
      };

      await DatabaseMethods().addFoodItem(addItem, value!).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Food Item has been added Successfully",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );

        // Clear fields
        namecontroller.clear();
        pricecontroller.clear();
        detailcontroller.clear();
        setState(() {
          selectedImage = null;
          selectedAssetImage = null;
          this.value = null;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Please fill all fields and select an image",
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Image Source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("From Gallery"),
              onTap: () {
                Navigator.pop(context);
                getImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.folder_special),
              title: Text("From Default App Images"),
              onTap: () {
                Navigator.pop(context);
                _showAssetImagesDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAssetImagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Default Image"),
        content: Container(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: assetImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  selectAssetImage(assetImages[index]);
                  Navigator.pop(context);
                },
                child: Image.asset(assetImages[index], fit: BoxFit.cover),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Color(0xFF373866),
          ),
        ),
        centerTitle: true,
        title: Text("Add Item", style: AppWidget.HeadLineTextFieldStyle()),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: 50.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload the Item Picture",
                style: AppWidget.SemiBoldTextFieldStyle(),
              ),
              SizedBox(height: 20.0),
              (selectedImage == null && selectedAssetImage == null)
                  ? GestureDetector(
                      onTap: () {
                        _showImageSourceDialog();
                      },
                      child: Center(
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: GestureDetector(
                        onTap: () {
                          _showImageSourceDialog();
                        },
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: selectedImage != null
                                  ? Image.file(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      selectedAssetImage!,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 30.0),
              Text("Item Name", style: AppWidget.SemiBoldTextFieldStyle()),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: namecontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Item Name",
                    hintStyle: AppWidget.LightTextFieldStyle(),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              Text("Item Price", style: AppWidget.SemiBoldTextFieldStyle()),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: pricecontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Item Price",
                    hintStyle: AppWidget.LightTextFieldStyle(),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              Text("Item Detail", style: AppWidget.SemiBoldTextFieldStyle()),
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  maxLines: 6,
                  controller: detailcontroller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Item Detail",
                    hintStyle: AppWidget.LightTextFieldStyle(),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                "Select Category",
                style: AppWidget.SemiBoldTextFieldStyle(),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    items: fooditems
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: ((value) => setState(() {
                      this.value = value;
                    })),
                    dropdownColor: Colors.white,
                    hint: Text("Select Category"),
                    iconSize: 36,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    value: value,
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              GestureDetector(
                onTap: () {
                  uploadItem();
                },
                child: Center(
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
