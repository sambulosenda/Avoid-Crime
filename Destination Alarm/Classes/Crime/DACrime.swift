import Foundation
import CoreData


/// MARK: - DACrime
class DACrime: NSManagedObject {

    /// MARK: - property
    @NSManaged var crime_id: NSNumber
    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var size: NSNumber
    @NSManaged var timestamp: NSDate


    /// MARK: - class method

    /**
     * fetch datas from coredata
     * @param lat latitude
     * @param long longitude
     * @param radius radius of miles
     * @return Array<DACrime>
     */
/*
    class func fetch(#lat: NSNumber, long: NSNumber, radius: radius) -> Array<DACrime> {

        var context = DACoreDataManager.sharedInstance.managedObjectContext

        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("DACrime", inManagedObjectContext:context)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        let predicaets = [
            NSPredicate(format: "lat < %@", NSNumber(float: lat.floatValue + 1.0)),
            NSPredicate(format: "lat > %@", NSNumber(float: lat.floatValue - 1.0)),
            NSPredicate(format: "long < %@", NSNumber(float: long.floatValue + 1.0)),
            NSPredicate(format: "long > %@", NSNumber(float: long.floatValue - 1.0)),
        ]
        fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates(predicaets)

        var error: NSError? = nil
        let sensorDatas = context.executeFetchRequest(fetchRequest, error: &error) as! Array<DACrime>
        return sensorDatas
    }
*/


    /**
     * save json datas to coredata
     * @param json JSON
     *  [
     *      {
     *          "pathToRoot":[
     *              16,
     *              0
     *          ],
     *          "box":{"lat1": 37.7832593295025, "lon1": -122.415910622743, "lat2": 37.7849141859562, "lon2": -122.411115854179},
     *          "centroid":{
     *              "lat": 37.7841468713255,
     *              "lon": -122.41394143505319
     *          },
     *          "size": 89,
     *          "polygon":[{"lat": 37.7850141859562, "lon": -122.41140909352606 }, {"lat": 37.78461206112599, "lon": -122.411015854179}],
     *          "points":[{"sid": 12564300, "lat": 37.7848656939526, "lon": -122.412784096502 }, ...]
     *          "id": 22
     *      },
     *      ...
     *  ]
     * @param date timestamp
     */
    class func save(#json: JSON, date: NSDate) {
        let crimeDatas: Array<JSON> = json.arrayValue

        for crimeData in crimeDatas {
            DACrime.insertCrime(json: crimeData, date: date)
        }

        var error: NSError? = nil
        var context = DACoreDataManager.sharedInstance.managedObjectContext
        !context.save(&error)
    }

    /**
     * insert new crime
     * @param json JSON
     *  {
     *      "pathToRoot":[
     *          16,
     *          0
     *      ],
     *      "box":{"lat1": 37.7832593295025, "lon1": -122.415910622743, "lat2": 37.7849141859562, "lon2": -122.411115854179},
     *      "centroid":{
     *          "lat": 37.7841468713255,
     *          "lon": -122.41394143505319
     *      },
     *      "size": 89,
     *      "polygon":[{"lat": 37.7850141859562, "lon": -122.41140909352606 }, {"lat": 37.78461206112599, "lon": -122.411015854179}],
     *      "points":[{"sid": 12564300, "lat": 37.7848656939526, "lon": -122.412784096502 }, ...]
     *      "id": 22
     *  }
     * @param date timestamp
     */
    class func insertCrime(#json: JSON, date: NSDate) {
        let children = json["children"].arrayValue

        // insert child
        if children.count == 0 {
            var context = DACoreDataManager.sharedInstance.managedObjectContext
            var crime = NSEntityDescription.insertNewObjectForEntityForName("DACrime", inManagedObjectContext: context) as! DACrime
            crime.crime_id = json["id"].numberValue
            if let centroid = json["centroid"].dictionary {
                crime.lat = centroid["lat"]!.numberValue
                crime.long = centroid["lon"]!.numberValue
            }
            crime.size = json["size"].numberValue
            crime.timestamp = date
        }

        // insert children
        for child in children {
            DACrime.insertCrime(json: child, date: date)
        }
    }
}
