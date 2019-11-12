


import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(name: String, temp: Double, description: String)
}

struct WeatherManager{
    var delegate: WeatherManagerDelegate?
    let codes = [2 : "cloud.bolt", 3 : "cloud.drizzle", 5 : "cloud.rain", 6 : "cloud.snow",
                 7 : "sun.haze"]
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b37e7223de94fe914d62b2252cb03771&units=imperial"
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if (error != nil){
                    print(error!)
                    return
                }
                if let safeData = data {
                    let (cityName, cityTemp, cityDescrip) = self.parseJSON(weatherData: safeData)
                    if (cityName != ""){
                        self.delegate?.didUpdateWeather(name: cityName, temp: cityTemp, description: cityDescrip)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    /*
     Parses JSON received from weather api
     Returns a tuple with the city name,
     city temp, and the weather description.
     Returns an essentially empty tuple for
     easy error checking on failure.
     */
    func parseJSON(weatherData: Data) -> (name: String, temp: Double, desc : String) {
        let decoder = JSONDecoder()
        var descrip: String = ""
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            //Get Description
            if ((decodedData.weather[0].id) / 100) == 8{
                if ((decodedData.weather[0].id) % 100) == 0{
                    descrip = "sun.min"
                }
                else{
                    descrip = "cloud"
                }
            }else{
                if let description = codes[(decodedData.weather[0].id) / 100]{
                    descrip = description
                }
            }
            //Get temperature
            let temp = decodedData.main.temp
            let cityName = decodedData.name
            return (cityName,temp,descrip)
            
            
        } catch{
            print(error)
            return ("",0.0,"")
        }
        
    }
    

    
}
