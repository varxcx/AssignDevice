//
//  ViewController.swift
//  AssingDevice
//
//  Created by Vardhan Chopada on 4/23/23.
//

import UIKit
import AVFoundation
import Lottie


class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    
    var tableView: UITableView!
    var infoArray: [String] = [""]
    let animationView2 = AnimationView()
    var starView: UIView!
    var starLayer: CAShapeLayer!
    let button = UIButton(type: .system)
    var Tapped = false
    
    
    
    
    override func viewDidLoad() {
        
        let animationView = AnimationView()
        let animation = Animation.named("the-nyan-cat", bundle: Bundle.main)
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.animation = animation
        animationView.loopMode = .loop
        animationView.play()
        
        
        let animation2 = Animation.named("Background", bundle: Bundle.main)
        animationView2.frame = self.view.bounds
        animationView2.contentMode = .scaleAspectFill
        animationView2.animation = animation2
        animationView2.loopMode = .loop
        animationView2.play()
        self.view.addSubview(animationView2)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 1.5, y: 0))
        path.addLine(to: CGPoint(x: 3.5, y: 3))
        path.addLine(to: CGPoint(x: 0, y: 3))
        path.addLine(to: CGPoint(x: 1.5, y: 0))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.lineJoin = .round
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        starLayer = shapeLayer
        
        // Create the view to hold the shooting star
        starView = UIView(frame: animationView.bounds)
        starView.backgroundColor = UIColor.clear
        animationView2.addSubview(starView)
        
        
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isUserInteractionEnabled = false
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = UIColor.clear
        
        view.addSubview(animationView)
        
        
        
        // Stop the animation after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 1.0, animations: {
                animationView.alpha = 0.0
            }, completion: { _ in
                animationView.removeFromSuperview()
                self.addJokeButton()
                self.view.addSubview(self.tableView)
                NSLayoutConstraint.activate([
                    self.tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    self.tableView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                    self.tableView.widthAnchor.constraint(equalToConstant: 300),
                    self.tableView.heightAnchor.constraint(equalToConstant: 500)
                ])
            })
        }
        
        let device = UIDevice.current
        let udid = device.identifierForVendor?.uuidString ?? ""
        let name = device.name
        let version = device.systemVersion
        let modelName = device.model
        let cpuInfo = UIDevice.hardwareModel()
        let gpuInfo = UIDevice.getGPUInfo()
        let storage = UIDevice.getDeviceStorageInfo()
        let battery = UIDevice.getBatteryHealth()
        let cameraMegapixel = AVCaptureDevice.cameraMegapixel()
        let cameraAperture = AVCaptureDevice.cameraAperture()
        let osName = device.systemName
        
        infoArray = [
            "Device UUID: \(udid)",
            "Device Name: \(name)",
            "System Version: \(version)",
            "Device Model: \(modelName)",
            "CPU Info: \(cpuInfo ?? "")",
            "GPU Info: \(gpuInfo ?? "")",
            "Device Storage Info: \(storage ?? (0.0,0.0))",
            "Battery Health: \(battery ?? 0)",
            "Camera Megapixel: \(cameraMegapixel ?? 0)",
            "Camera Aperture: \(cameraAperture ?? 0)",
            "OS Name: \(osName)"
        ]
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // Get the touch location and add the shooting star layer
            let location = touch.location(in: starView)
            starLayer.position = location
            starView.layer.addSublayer(starLayer)
            
            // Animate the shooting star
            let endPoint = CGPoint(x: location.x + CGFloat.random(in: -100...100), y: location.y + CGFloat.random(in: -100...100))
            let duration = 1.0
            let path = UIBezierPath()
            path.move(to: location)
            path.addQuadCurve(to: endPoint, controlPoint: CGPoint(x: location.x, y: location.y - 200))
            let animation = CAKeyframeAnimation(keyPath: "position")
            animation.path = path.cgPath
            animation.duration = duration
            starLayer.add(animation, forKey: nil)
            
            // Remove the shooting star when it's done
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.starLayer.removeFromSuperlayer()
            }
        }
    }
    
    func makeLabelBlink(_ label: UILabel) {
        UIView.animate(withDuration: 1.6, delay: 0.0, options: [.autoreverse, .repeat], animations: {
            label.alpha = 0.5
        }, completion: nil)
    }
    
    
    @objc func fetchJoke() {
        guard let url = URL(string: "https://api.chucknorris.io/jokes/random") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching joke: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(JokeResponse.self, from: data)
                DispatchQueue.main.async {
                    self.showJoke(result.value)
                }
            } catch {
                print("Error decoding joke: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func showButton() {
        // Set up the button

        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.setTitle("Surprise(Click on Me)", for: .normal)
        button.setTitleColor(.lightText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
            
            
        ])
        
    }
    
    @objc func buttonTapped() {
        // Open the link in a web browser
        if let url = URL(string: "https://youtu.be/dQw4w9WgXcQ") {
            UIApplication.shared.open(url)
        }
        
        Tapped = true
        
        // Generate a random time interval between 0 and 5 seconds
        let randomTime = TimeInterval(arc4random_uniform(5))
        
        // Start a timer with the random time interval
        Timer.scheduledTimer(withTimeInterval: randomTime, repeats: false) { [weak self] timer in
            self?.button.removeFromSuperview()
        }
        
        
    }
    
    func addJokeButton() {
        let jokeButton = UIButton()
        jokeButton.setTitle("Wanna hear a joke?", for: .normal)
        jokeButton.setTitleColor(.lightText, for: .normal)
        jokeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(jokeButton)
        
        if Tapped == false {
            // Generate a random time interval between 0 and 20 seconds
            let randomTime = TimeInterval(arc4random_uniform(20))
            
            // Start a timer with the random time interval
            Timer.scheduledTimer(withTimeInterval: randomTime, repeats: false) { [weak self] timer in
                self?.showButton()
            }
        }
        
        NSLayoutConstraint.activate([
            jokeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            jokeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            jokeButton.widthAnchor.constraint(equalToConstant: 200),
            jokeButton.heightAnchor.constraint(equalToConstant: 50)
            
            
        ])
        
        jokeButton.addTarget(self, action: #selector(fetchJoke), for: .touchUpInside)
    }
    
    func showJoke(_ joke: String) {
        
        
        let alertController = UIAlertController(title: "Joke Time!", message: joke, preferredStyle: .alert)
        alertController.view.layer.cornerRadius = 15
        alertController.view.backgroundColor = .blue
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Get tap location
        let tapLocation = gestureRecognizer.location(in: animationView2)
        
        // Create emitter layer
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = tapLocation
        emitterLayer.emitterSize = CGSize(width: 1, height: 1)
        emitterLayer.emitterShape = .point
        emitterLayer.birthRate = 1
        emitterLayer.lifetime = 1
        
        // Create emitter cell
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "laser")?.cgImage
        emitterCell.birthRate = 200
        emitterCell.lifetime = 1.5
        emitterCell.velocity = 100
        emitterCell.velocityRange = 50
        emitterCell.emissionLongitude = CGFloat.random(in: -CGFloat.pi...CGFloat.pi)
        emitterCell.emissionRange = CGFloat.pi / 4
        emitterCell.scale = 0.3
        emitterCell.scaleRange = 0.2
        
        // Add emitter cell to emitter layer
        emitterLayer.emitterCells = [emitterCell]
        
        // Add emitter layer to animation view's layer
        animationView2.layer.addSublayer(emitterLayer)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell with the "Cell" identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.clear
        
        cell.contentView.layer.cornerRadius = 10
        
        
        // Create a UILabel and add it to the cell's content view
        let label = UILabel()
        label.text = infoArray[indexPath.row]
        label.textAlignment = .center
        label.textColor = .lightText
        label.shadowColor = UIColor.gray
        label.shadowOffset = CGSize(width: 3, height: 3)
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        label.numberOfLines = 0 // Set the number of lines to be unlimited
        label.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        label.sizeToFit() // Resize the label to fit its content
        makeLabelBlink(label)
        
        // Calculate the required height of the label based on its text
        let labelHeight = label.sizeThatFits(CGSize(width: cell.frame.width, height: CGFloat.greatestFiniteMagnitude)).height
        
        // Update the cell's height based on the label's required height
        cell.frame.size.height = labelHeight
        
        
        // Center the label within the cell's content view
        label.center = cell.contentView.center
        cell.contentView.addSubview(label)
        
        // Return the cell
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Create a UILabel and calculate its height based on the cell's width
        let label = UILabel()
        label.text = infoArray[indexPath.row]
        label.numberOfLines = 0
        label.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0)
        label.sizeToFit()
        return label.frame.size.height + 10
    }
}

struct JokeResponse: Codable {
    let iconURL: URL
    let id: String
    let url: URL
    let value: String
    
    private enum CodingKeys: String, CodingKey {
        case iconURL = "icon_url"
        case id
        case url
        case value
    }
}
