//api call:
//api.openweathermap.org/data/2.5/weather?appid=*key*&q={city name}&units=imperial

import UIKit

class WeatherViewController: UIViewController, UITextFieldDelegate, WeatherManagerDelegate {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityTextField.delegate = self
        weatherManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkDefaults()
        
    }

    @IBAction func searchClicked(_ sender: UIButton) {
        cityTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        cityTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        } else{
            textField.placeholder = "Enter in location"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //use searchtextfield to get weather
        if let city = cityTextField.text{
            weatherManager.fetchWeather(cityName: city)
        }
        cityTextField.text = ""
    }
    
    func didUpdateWeather(name: String, temp: Double, description: String){
        DispatchQueue.main.async {
            self.temperatureLabel.text = String(format: "%.0f", temp)
            self.conditionImageView.image = UIImage(systemName: description)
            self.cityLabel.text = name
        }
    }
        
    /*
     Checks user defaults, if it users first time opening
     then it will ask for a hometown. Otherwise it will
     load hometown
     */
    func checkDefaults(){
        let defaults = UserDefaults.standard
        if let check = defaults.object(forKey: "Initialized") as? Bool{
            if (check == true){
                if let hometown = defaults.object(forKey: "hometown"){
                    weatherManager.fetchWeather(cityName: hometown as! String)
                }
                
            }
        } else{
            defaults.set(true, forKey: "Initialized")
            let alert = UIAlertController(title: "Enter Hometown", message: "This will be stored as your default town", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Enter Hometown Here" })
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if let name = alert.textFields?.first?.text {
                    defaults.set(name, forKey: "hometown")
                    self.weatherManager.fetchWeather(cityName: name)
                }
            }))
            self.present(alert,animated: true)
        }
    }

}

