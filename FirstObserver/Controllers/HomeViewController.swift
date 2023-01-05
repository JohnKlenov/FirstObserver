//
//  HomeViewController.swift
//  FirstObserver
//
//  Created by Evgenyi on 8.08.22.
//

// точка входа - HomeViewControllerю
//  if [userName:nil] { let randomUID(+ String("RANDOM")) + ref in UserAccaunt at UID } else { не создаем }
// SignInViewController -> if creatUser {
// save email for user.uid in Realtime Database
// мы переименуем iserAccaunt(тот что мы сами сгенерировали на тот который сгенерировал Firebase) это если он был создан(есть идея добавить кнопку перейти к авторизации/регистрации на экране onboardingVC).
// иначе просто создаем UserAccaunt
// let userRef = self.ref.child((result?.user.uid)!)
// userRef.setValue(["email": result?.user.email])}






import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseStorageUI
import MapKit


enum SwitchCaseNavigationHomeVC {
    case popularProductCell
    case brandCell
    case shopingMall
}

protocol ViewsHomeVCNavigationDelegate: AnyObject {
    func  destinationVC(indexPath: Int, forCell: SwitchCaseNavigationHomeVC, refPath: String)
}



class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    
//    weak var delegate: AddedToCardProductsHVCDelegate?
    lazy var topView = UIView()
    static let userDefaults = UserDefaults.standard
    
    var homeModel = [HomeModel]()
    
    private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.color = .black
        loader.isHidden = true
        loader.hidesWhenStopped = true
        loader.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        return loader
    }()
    
    private var activityContainerView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.backgroundColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
        view.layer.cornerRadius = 8
        return view
    }()
    
   
    
    var ref: DatabaseReference!
    var storage:Storage!
    private var handle: AuthStateDidChangeListenerHandle?
//    var currentUser: User?
    
    var arrayInArray = [String:Any]() {
        didSet {
            if arrayInArray.count == 3 {
//                print("arrayInArray arrayInArray arrayInArray\(arrayInArray.count)")
                self.homeTableView.reloadData()
                loader.stopAnimating()
                activityContainerView.removeFromSuperview()
                self.tabBarController?.view.isUserInteractionEnabled = true
            }
        }
    }
    
    var addedToCardProducts:[PopularProduct] = [] {
        didSet {
            print("&&&&& addedToCardProducts addedToCardProducts addedToCardProducts addedToCardProducts &&&&&")
            print("addedToCardProducts \(self.addedToCardProducts)")
//            delegate?.allProductsToCard(productsToCard: addedToCardProducts)
        }
    }
    
    var arrayPin:[PlacesTest] = []
    var arrayPins:[PlacesFB] = [] {
        didSet {
//            print("arrayPins didSet arrayPins didSet arrayPins didSet")
            getPlaces()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // addStateDidChangeListener работает в режиме наблюдателя и постоянно делает запросы в сеть
        // При слиянии anonymous user с permanent user Auth.auth().addStateDidChangeListener не срабатывает!
        // signIn and signOut срабатывает!
       handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            print("%%%%%%% auth.currentUser?.isAnonymous - \(String(describing: auth.currentUser?.isAnonymous))")
            print("%%%%%%% addStateDidChangeListener user?.isAnonymous - \(String(describing: user?.isAnonymous))")
            if user == nil {
                print("Auth.auth().currentUser == nil  Auth.auth().currentUser == nil  Auth.auth().currentUser == nil ")
                self.addedToCardProducts = []
                let refFBR = Database.database().reference()
                Auth.auth().signInAnonymously { (authResult, error)
                    in
                    guard let user = authResult?.user else {return}
                    print("create user anonymous - \(user.uid)")
                    let uid = user.uid
                    refFBR.child("usersAccaunt/\(uid)").setValue(["uidAnonymous":user.uid])
            }
            } else {
                print("addStateDidChangeListener user?.uid - \(String(describing: user?.uid))")
                print("addStateDidChangeListener user no null!")
            }
           
           print("!!!!!!!! userId - \(String(describing: user?.uid)) @@@@@@@@@@")
           self.ref.child("usersAccaunt/\(user?.uid ?? "")").observe(.value) { [weak self] (snapshot) in
               for item in snapshot.children {
                   let item = item as! DataSnapshot
                   print("item - \(item.key)")
                   switch item.key {
                   case "AddedProducts":
                       var arrayProduct = [PopularProduct]()
                       
                       for item in item.children {
                           let product = item as! DataSnapshot
                           
                           var arrayMalls = [String]()
                           var arrayRefe = [String]()
                           
                           
                           for mass in product.children {
                               let item = mass as! DataSnapshot
                               
                               switch item.key {
                               case "malls":
                                   for it in item.children {
                                       let item = it as! DataSnapshot
                                       if let refDictionary = item.value as? String {
                                           arrayMalls.append(refDictionary)
                                       }
                                   }
                                   
                               case "refImage":
                                   for it in item.children {
                                       let item = it as! DataSnapshot
                                       if let refDictionary = item.value as? String {
                                           arrayRefe.append(refDictionary)
                                       }
                                   }
                               default:
                                   break
                               }
                               
                           }
                           let productModel = PopularProduct(snapshot: product, refArray: arrayRefe, malls: arrayMalls)
                           arrayProduct.append(productModel)
                       }
                       self?.addedToCardProducts = arrayProduct
                   default:
                       break
                   }
               }
           }
        }
        
        self.tabBarController?.view.isUserInteractionEnabled = false
        activityContainerView.addSubview(loader)
        loader.center = activityContainerView.center
        self.view.addSubview(activityContainerView)
        loader.isHidden = false
        activityContainerView.center = self.view.center
        loader.startAnimating()
       
        storage = Storage.storage()
        ref = Database.database().reference()
        
        self.title = "Observer"
        calculateHeightCell()
        homeTableView.dataSource = self
        homeTableView.delegate = self
        addTopView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
       
        
        ref.child("previewMalls").observe(.value) { [weak self] (snapshot) in
            var arrayMalls = [PreviewCategory]()
            for item in snapshot.children {
                let mall = item as! DataSnapshot
                let model = PreviewCategory(snapshot: mall)
                arrayMalls.append(model)
            }
            
            self?.arrayInArray["malls"] = arrayMalls
            
        }
        
        ref.child("previewBrands").observe(.value) { [weak self] (snapshot) in
            
            var arrayBrands = [PreviewCategory]()
            for item in snapshot.children {
                let brand = item as! DataSnapshot
                let model = PreviewCategory(snapshot: brand)
                arrayBrands.append(model)
            }
            
            self?.arrayInArray["brands"] = arrayBrands
        }
        
        
        ref.child("popularProduct").observe(.value) { [weak self] (snapshot) in
            
            var arrayProduct = [PopularProduct]()
            
            for item in snapshot.children {
                let product = item as! DataSnapshot
                
                var arrayMalls = [String]()
                var arrayRefe = [String]()
                
                
                for mass in product.children {
                    let item = mass as! DataSnapshot
                    
                    switch item.key {
                    case "malls":
                        for it in item.children {
                            let item = it as! DataSnapshot
                            if let refDictionary = item.value as? String {
                                arrayMalls.append(refDictionary)
                            }
                        }
                        
                    case "refImage":
                        for it in item.children {
                            let item = it as! DataSnapshot
                            if let refDictionary = item.value as? String {
                                arrayRefe.append(refDictionary)
                            }
                        }
                    default:
                        break
                    }
                    
                }
                let productModel = PopularProduct(snapshot: product, refArray: arrayRefe, malls: arrayMalls)
                arrayProduct.append(productModel)
            }
            self?.arrayInArray["popularProduct"] = arrayProduct
        }
        
        
        ref.child("Places").observe(.value) {  [weak self] (snapshot) in
            
            var arrayPin = [PlacesFB]()
            for place in snapshot.children {
//                print("ref Places snapshot")
                let place = place as! DataSnapshot
                let model = PlacesFB(snapshot: place)
                arrayPin.append(model)
                
            }
            self?.arrayPins = arrayPin
        }
        
        
        

        removeTopView()
    }
    
    
    func getPlaces() {
        
//        print(" getPlaces getPlaces getPlaces getPlaces")
        
        
        let tcNew = arrayPins.map { $0.name }
        let tcOld = arrayPin.map { $0.title ?? " " }
//        print("count tcNew - \(tcNew)")
//        print("count tcOld - \(tcOld)")
        
        let oldPins = Set(tcOld)
        let newPins = Set(tcNew)
        
//        print("count newPins - \(newPins)")
//        print("count oldPins - \(oldPins)")
        
        if oldPins != newPins {
            
//            print("oldPins != newPins oldPins != newPins oldPins != newPins oldPins != newPins oldPins != newPins")
            arrayPins.forEach { (place) in
                self.getImagefromStorage(refImage: place.refImage) { (image) in
                    let pin = PlacesTest(title: place.name, locationName: place.address, discipline: "Торговый центр", coordinate: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude), image: image)
                    self.arrayPin.append(pin)
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPresentation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        if let handle = handle {
//            Auth.auth().removeStateDidChangeListener(handle)
//            print("viewWillDisappear - handle dead!!!")
//        }
//        ref.removeAllObservers()
        // отключить прослушиватель состояний
//        Auth.auth().removeStateDidChangeListener(handle!)
        
    }
    
    
    

    private func getImagefromStorage(refImage:String, completionHandler: @escaping (UIImage) -> Void) {
        let ref = storage.reference(forURL: refImage)
        let megaBite = Int64(1*1024*1024)
        ref.getData(maxSize: megaBite) { (data, error) in
            guard let imageData = data else {
                let defaultImage = UIImage(named: "DefaultImage")!
                completionHandler(defaultImage)
                return
            }
            if let image = UIImage(data: imageData) {
                completionHandler(image)
            }
        }
    }
    
    // MARK: - im Hiding HomeViewController -
    
    private func configureView() {
        
        let rootFrame = UIScreen.main.bounds
        topView.frame = rootFrame
        topView.backgroundColor = .black
        self.view.addSubview(topView)
    }
    
    private func addTopView() {
        let appAlreadeSeen = HomeViewController.userDefaults.bool(forKey: "appAlreadeSeen")
        if appAlreadeSeen == false {
            configureView()
        }
    }
    
    private func removeTopView() {
        let appAlreadeSeen = HomeViewController.userDefaults.bool(forKey: "appAlreadeSeen")
        if appAlreadeSeen == true {
            self.deleteView()
        }
    }
    
    func deleteView() {
        topView.removeFromSuperview()
    }
        
    
    
    
    // MARK: - Start Onboarding -
    
        func startPresentation() {
//            HomeViewController.userDefaults.set(false, forKey: "appAlreadeSeen")
            let appAlreadeSeen = HomeViewController.userDefaults.bool(forKey: "appAlreadeSeen")
            if appAlreadeSeen == false {
                if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? PageViewController {
                    pageViewController.modalPresentationStyle = .fullScreen
                    self.present(pageViewController, animated: true, completion: nil)
                }
            }
        }
    
    
    
    
    // MARK: - TableViewCell Calculate height -
    
    
    func calculateHeightCell() {
    
        
        let heightTableViewFrame = homeTableView.frame.height
        
        let soppingModel = HomeModel(heightCell: heightTableViewFrame * CGFloat(0.3))
        let brandModel = HomeModel(heightCell: heightTableViewFrame * CGFloat(0.2))
//        let productModel = HomeModel(heightCell: heightTableViewFrame)
        
        homeModel = [soppingModel, brandModel]
        
    }
    
}





// MARK: - DataSource and Delegate Table View -


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayInArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let shopingCell = tableView.dequeueReusableCell(withIdentifier: "ShopingMall") as! ShopingMallCell
            let malls = arrayInArray["malls"] as! [PreviewCategory]
            
            shopingCell.delegate = self
            shopingCell.configureCell(arrayMalls: malls)
            
            shopingCell.backgroundColor = .black
            return shopingCell
        case 1:
            let brandCell = tableView.dequeueReusableCell(withIdentifier: "BrandCell") as! BrandCell
            let brands = arrayInArray["brands"] as! [PreviewCategory]
            brandCell.configureCell(arrayBrands: brands)
            brandCell.delegate = self
            brandCell.backgroundColor = .blue
            return brandCell
        case 2:
            let popularCell = tableView.dequeueReusableCell(withIdentifier: "PopularProductCell") as! PopularProductCell
            popularCell.delegate = self
            let product = arrayInArray["popularProduct"] as! [PopularProduct]
            popularCell.configureCell(arrayProduct: product)
            popularCell.backgroundColor = .brown
            return popularCell
        default:
            print("Error")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return homeModel[indexPath.row].heightTableViewCell
        case 1:
            return homeModel[indexPath.row].heightTableViewCell
        case 2:

            return UITableView.automaticDimension
        default:
            print("Error")
            return CGFloat()
        }
    }
    
}



//extension HomeViewController: HomeViewControllerDelegate {
//
//    func goToBrandsVC(_ indexPath: Int) {
//        print("\(indexPath)")
//        performSegue(withIdentifier: "goToBrandVC", sender: nil)
//    }
//
//}
//

extension HomeViewController: ViewsHomeVCNavigationDelegate {
   
    func  destinationVC(indexPath: Int, forCell: SwitchCaseNavigationHomeVC, refPath: String) {
        
        switch forCell {
        
        case .popularProductCell:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let productVC = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
            let product = self.arrayInArray["popularProduct"] as! [PopularProduct]
            
            var placesArray:[PlacesTest] = []
            let malls = product[indexPath].malls
            arrayPin.forEach { (places) in
                if malls.contains(places.title ?? "") {
                    placesArray.append(places)
                }
            }
            addedToCardProducts.forEach { (addedProduct) in
                if addedProduct.model == product[indexPath].model {
                    productVC.isAddedToCard = true
                }
            }
            
            productVC.fireBaseModel = product[indexPath]
            productVC.arrayPin = placesArray
            self.navigationController?.pushViewController(productVC, animated: true)
            // передать делегат
        case .brandCell:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let brandVC = storyboard.instantiateViewController(withIdentifier: "BrandsViewController") as! BrandsViewController
            let ref = Database.database().reference(withPath: "brands/\(refPath)")
            brandVC.incomingRef = ref
            brandVC.arrayPin = arrayPin
            self.navigationController?.pushViewController(brandVC, animated: true)
            
        case .shopingMall:
            
            let mallVC = UIStoryboard.vcById("MallViewController") as! MallViewController
            mallVC.refPath = refPath
            mallVC.arrayPin = arrayPin
            mallVC.brandsMall = arrayInArray["brands"] as! [PreviewCategory]
            self.navigationController?.pushViewController(mallVC, animated: true)
        }

    }
    
    
}



    

