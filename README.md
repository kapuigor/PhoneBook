# PhoneBook
Phone book app

Класс MainViewController (файл MainViewController) является классом главного экрана, в котором реализован список контактов в табличном виде,
поиск по имен, фамилии и email, а также кнопка добавления нового контакта.

Класс NewContactViewController (файл NewContactViewController) является классом второго экрана, с помощью которого можно добавлять данные в новый
контакт, либо просматривать или редактировать уже существующие контакты.

Класс Contact (файл ContactModel) реализует модель хранения данных контакта, описывает все поля, которые доступны при 
работе с контактом.

Кдасс StorageManager (файл StorageManager) сохраняет и удаляет контакты в базу данных, основанную на RealmSwift.

Класс CustomTableViewCell (файл CustomTableViewCell), реализующий ячейку контакта в классе MainViewController.

https://user-images.githubusercontent.com/22479739/134815947-1cfed43f-b838-40a6-b897-1fcfc58384a3.mp4

