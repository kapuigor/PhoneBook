//
//  NewContactViewController.swift
//  PhoneBook
//
//  Created by Игорь Капустин on 22.09.2021.
//

import UIKit

class NewContactViewController: UITableViewController, UITextFieldDelegate {
    
    var currentContact: Contact?
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    @IBOutlet var contactName: UITextField!
    @IBOutlet var contactSecondName: UITextField!
    @IBOutlet var contactDateOfBirth: UITextField!
    @IBOutlet var contactCompany: UITextField!
    @IBOutlet var contactEmail: UITextField!
    @IBOutlet var contactPhoneNumber: UITextField!
    
    let datePicker = UIDatePicker()
    
    private let maxPhoneNumberCount = 11
    private let regex = try! NSRegularExpression(pattern: "[\\+\\s-\\(\\)]", options: .caseInsensitive)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactPhoneNumber.delegate = self
        contactPhoneNumber.keyboardType = .numberPad
        contactPhoneNumber.addTarget(self, action: #selector(phoneNumberValidation), for: .editingDidEnd)
        
        contactName.delegate = self
        contactName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        contactSecondName.delegate = self
        contactSecondName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        contactDateOfBirth.delegate = self
        contactDateOfBirth.inputView = datePicker
        datePicker.datePickerMode = .date
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace, doneButton], animated: true)
        contactDateOfBirth.inputAccessoryView = toolBar
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        contactCompany.delegate = self
        
        contactEmail.delegate = self
        contactEmail.addTarget(self, action: #selector(emailTextFieldChanged), for: .editingDidEnd)
                
        saveButton.isEnabled = false

        setupEditScreen()

    }
                    
    

    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row >= 0 {
            view.endEditing(true)
        }
    }
    
    func saveContact() {
        
        let newContact = Contact(name: contactName.text!,
                                 secondName: contactSecondName.text!,
                                 dateOfBirth: contactDateOfBirth.text,
                                 company: contactCompany.text,
                                 email: contactEmail.text,
                                 phoneNumber: contactPhoneNumber.text)
        
        if currentContact != nil {
            try! realm.write {
                currentContact?.name = newContact.name
                currentContact?.secondName = newContact.secondName
                currentContact?.dateOfBirth = newContact.dateOfBirth
                currentContact?.company = newContact.company
                currentContact?.email = newContact.email
                currentContact?.phoneNumber = newContact.phoneNumber
            }
        } else {
            StorageManager.saveObject(newContact)
        }
        
    }
    
    private func setupEditScreen() {
        if currentContact != nil {
            
            setupNavigationBar()
            
            contactName.text = currentContact?.name
            contactSecondName.text = currentContact?.secondName
            contactDateOfBirth.text = currentContact?.dateOfBirth
            contactCompany.text = currentContact?.company
            contactEmail.text = currentContact?.email
            contactPhoneNumber.text = currentContact?.phoneNumber
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = String("\(currentContact!.name) \(currentContact!.secondName)")
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    
    // Setting birth date
    @objc func doneAction() {
        view.endEditing(true)
        }
    
    @objc func dateChanged() {
        getDateFromPicker()
    }
    
    func getDateFromPicker() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        contactDateOfBirth.text = dateFormatter.string(from: datePicker.date)
    }
    
    
    // Mask for phone number
    func format(phoneNumber: String, shouldRemoveLastDigit: Bool) -> String {
        
        guard !(shouldRemoveLastDigit && phoneNumber.count <= 2) else { return "+" }
        
        let range = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: [], range: range, withTemplate: "")
        
        if number.count > maxPhoneNumberCount {
            let maxIndex = number.index(number.startIndex, offsetBy: maxPhoneNumberCount)
            number = String(number[number.startIndex..<maxIndex])
        }
        
        if shouldRemoveLastDigit {
            let maxIndex = number.index(number.startIndex, offsetBy: number.count - 1)
            number = String(number[number.startIndex..<maxIndex])
        }
        
        let maxIndex = number.index(number.startIndex, offsetBy: number.count)
        let regRange = number.startIndex..<maxIndex
        let pattern = "(\\d)(\\d{3})(\\d{3})(\\d{2})(\\d+)"
        number = number.replacingOccurrences(of: pattern, with: "$1 ($2) $3-$4-$5", options: .regularExpression, range: regRange)
        
        return "+" + number
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let fullString = (textField.text ?? "") + string
        if textField == contactPhoneNumber {
        textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: range.length == 1)
            return false
        } else {
            return true
        }
    }
    
    @objc func phoneNumberValidation() {
        if contactPhoneNumber.text!.count <= 10 {
            let alert = UIAlertController(title: "Wrong format", message: "The phone number must be, for example, +7(999)999-99-99", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }

    }
    
    
    // Hide the keyboard when clicking on "Done"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Email validation
    func emailValidation(_ enteringEmail: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: enteringEmail)
    }
    
    @objc private func emailTextFieldChanged() {
        if !emailValidation(contactEmail.text!) {
            let alert = UIAlertController(title: "Wrong format", message: "The Email must be, for example, ivan@gmail.ru", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    
    // Name and second Name valideation
    @objc private func textFieldChanged() {
        
        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZабвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ")
        
        if contactName.text?.rangeOfCharacter(from: characterSet.inverted) != nil {
            let alert = UIAlertController(title: "Wrong format", message: "The name must contain only letters", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        if contactSecondName.text?.rangeOfCharacter(from: characterSet.inverted) != nil {
            let alert = UIAlertController(title: "Wrong format", message: "The second name must contain only letters", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        if contactName.text?.isEmpty == false && contactSecondName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        
        if contactName.text?.rangeOfCharacter(from: characterSet.inverted) != nil || contactSecondName.text?.rangeOfCharacter(from: characterSet.inverted) != nil {
            saveButton.isEnabled = false
        }
    }
}

