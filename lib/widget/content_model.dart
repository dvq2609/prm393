class UnboardingContent {
  String image;
  String title;
  String description;

  UnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

List<UnboardingContent> contents = [
  UnboardingContent(
    description: "Pick your food from out menu\n More than 35 times",
    image: "images/screen1.png",
    title: "Select from our\n best menu",
  ),
  UnboardingContent(
    description: "You can pay cash on delivery\n and cart payment is available",
    image: "images/screen2.png",
    title: "Easy and online payment",
  ),
  UnboardingContent(
    description: "Delivery your food at your\n doorstep",
    image: "images/screen3.png",
    title: "Quickest delivery",
  ),


];
