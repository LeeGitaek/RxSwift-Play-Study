import UIKit
import RxSwift

var str = "Hello, playground"

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}


example(of: "just, of, from") {
     // 1
     let one = 1
     let two = 2
     let three = 3
     
     //2
     let observable:Observable<Int> = Observable<Int>.just(one)
     let observable2 = Observable.of([one, two, three])
     
     
   
}

example(of: "subscribe") {
     // 1
     let one = 1
     let two = 2
     let three = 3
    
    let observable = Observable.from([one,two, three])
    observable.subscribe({ (event) in
        print(event)
    })
    
    let observable2 = Observable.of([one,two, three])
    observable2.subscribe({ (event) in
        print(event)
    })
    
    observable.subscribe(onNext: { (element) in
        print(element)
    })
}

// ** Mark:sequence example ** //

let sequence = 0..<3
var iterator = sequence.makeIterator()
while let n = iterator.next() {
    print(n)
}




example(of: "empty") {
    let observable = Observable<Void>.empty()
    
    observable.subscribe(
        
        onNext: { (element) in
            print(element)
        }, onError: { (error) in
            print("error : \(error)")
        }, onCompleted: {
            print("completed")
        }
    )
}


example(of: "never") {
    let observable = Observable<Any>.never()
    
    observable
        .subscribe(
            onNext: { (element) in
                print(element)
            }, onError: { (error) in
                print(error)
            }, onCompleted: {
                print("completed")
            }
        )
}

example(of:"range") {
    
    let observable = Observable<Int>.range(start: 1, count: 10)
    
    observable
        .subscribe(onNext: { (i) in
            let n = Double(i)
            let fibonacci = Int(((pow(1.61803,n) - pow(0.61803,n)) / 2.23606).rounded())
            print(fibonacci)
        })
}


example(of: "dispose") {
    
    let observable = Observable.of("A","B","C")
    
    let subscription = observable.subscribe({ (event) in
        print(event)
    })
    subscription.dispose()

}


example(of:"DisposeBag") {
    let disposeBag = DisposeBag()
    
    Observable.of("A","B","C")
        .subscribe {
            print($0)
        }
        .disposed(by: disposeBag)
    
}

enum MyError:Error {
    case anError
}

example(of:"create") {
    let disposeBag = DisposeBag()
    
    Observable<String>.create({ (observer) -> Disposable in
        
        observer.onNext("1")
        
        observer.onCompleted()
        
        observer.onNext("?")
        
        return Disposables.create()
    })
    
    .subscribe(
        onNext: { print($0) },
        onError: { print($0) },
        onCompleted: { print("Completed") },
        onDisposed: { print("Disposed") }
    ).disposed(by: disposeBag)

}

example(of: "deferred") {
    
    let disposeBag = DisposeBag()
    
    var flip = false
    
    let factory: Observable<Int> = Observable.deferred {
        
        flip = !flip
        
        if flip {
            return Observable.of(1,2,3)
        } else {
            return Observable.of(4,5,6)
        }
    }
    
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0,terminator:"")
        })
        .disposed(by: disposeBag)
        
        print()
    }
}

example(of:"single") {
    
    /* 이따가 쓸 dispose bag 을 생성  */
    let disposeBag = DisposeBag()
    
    /* 디스크의 데이터를 읽으면서 발생할 수 있는 error enum 을 통해 정의함  */
    enum FileReadError : Error {
        case fileNotFound, unreadable, encodingFailed
    }
    
    /* 디스크의 파일로부터 텍스트를 불러와서 single 을 리턴하는 함수를 생성  */
    func loadText(from name:String) -> Single<String> {
        
        /* 싱글을 생성하고 리턴함  */
        return Single.create { single in
            // 4-1
            /* create method 의 subscribe 클로저는 반드시 disposable을 리턴해야하므로 리턴 값 생성 */
            let disposable = Disposables.create()
            
            // 4-2
            /*  */
            guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound))
                return disposable
            }
            
            // 4-3
            guard let data = FileManager.default.contents(atPath: path) else {
                single(.error(FileReadError.unreadable))
                return disposable
            }
            
            // 4-4
            /* single 을 생성하고 리턴함  */
            guard let contents = String(data: data,encoding: .utf8) else {
                single(.error(FileReadError.encodingFailed))
                return disposable
            }
            
            // 4-5
            single(.success(contents))
            return disposable
                              
        }
    }
    
    loadText(from: "Copyright")
             .subscribe{
                 switch $0 {
                 case .success(let string):
                     print(string)
                 case .error(let error):
                     print(error)
                 }
             }
             .disposed(by: disposeBag)
}



example(of:"never") {
    let observable = Observable<Any>.never()
    
    let disposeBag = DisposeBag()
    
    observable.do(
        onSubscribe: {
            print("Subscribed")
            
        }).subscribe(
            onNext: { (element) in
                print(element)
            },
            onCompleted: {
                print("completed")
            }
        ).disposed(by: disposeBag)
}

example(of: "never") {
    let observable = Observable<Any>.never()
    let disposeBag = DisposeBag()            // 1. 역시 dispose bag 생성
    
    observable
        .debug("never 확인")            // 2. 디버그 하고
        .subscribe()                    // 3. 구독 하고
        .disposed(by: disposeBag)     // 4. 쓰레기봉지에 쏙
}


example(of:"PublishSubject") {
    let subject = PublishSubject<String>()
    
    subject.onNext("Is anyone listening?")
    
    let subscriptionOne = subject
        .subscribe(onNext: { (string) in
            print(string)
        })
    
    subject.on(.next("1"))
    subject.onNext("2")
    
    let subscriptionTwo = subject
        .subscribe({ (event) in
            print("2)",event.element ?? event)
        })
    
    subject.onNext("3")
    
    subscriptionOne.dispose()
    subject.onNext("4")
    
    
    subject.onCompleted()
    subject.onNext("5")
    
    subscriptionTwo.dispose()
    
    let disposeBag = DisposeBag()
    
    subject
        .subscribe {
            print("3)",$0.element ?? $0)
        }
        .disposed(by: disposeBag)
    
    subject.onNext("?")
}




 func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
     print(label, event.element ?? event.error ?? event)
 }


 example(of: "BehaviorSubject") {

     // 4
     let subject = BehaviorSubject(value: "Initial value")
     let disposeBag = DisposeBag()
    
    subject.onNext("X")

         // 5
         subject
             .subscribe{
                 print(label: "1)", event: $0)
             }
             .disposed(by: disposeBag)

         // 7
         subject.onError(MyError.anError)

         // 8
         subject
             .subscribe {
                 print(label: "2)", event: $0)
             }
             .disposed(by: disposeBag)
 }


example(of: "ReplaySubject") {
   // 만약에 BehaviorSubject처럼 최근의 값외에 더 많은 것을 보여주고 싶다면 어떻게 해야할까? 예를 들어 검색창같이, 최근 5개의 검색어를 보여주고 싶을 수 있다.
    // 이럴 때 ReplaySubject를 사용할 수 있다.

     // 1
     
     let subject = ReplaySubject<String>.create(bufferSize: 2)
     let disposeBag = DisposeBag()

     // 2
     subject.onNext("1")
     subject.onNext("2")
     subject.onNext("3")

     // 3
     subject
         .subscribe {
             print(label: "1)", event: $0)
         }
         .disposed(by: disposeBag)

     subject
         .subscribe {
             print(label: "2)", event: $0)
         }
         .disposed(by: disposeBag)
    
    subject.onNext("4")
    
    subject.onError(MyError.anError)
    
    subject.dispose()
         subject.subscribe {
             print(label: "3)", event: $0)
             }
             .disposed(by: disposeBag)
    

    //최근 두개의 요소2,3은 각각의 구독자에게 보여진다. 값1은 방출되지 않는다. 왜냐하면 버퍼사이즈가 2니까.
 }


example(of: "Variable") {

    // 1
    let variable = Variable("Initial value")
    let disposeBag = DisposeBag()

    // 2
    variable.value = "New initial value"

    // 3
    variable.asObservable()
        .subscribe {
            print(label: "1)", event: $0)
        }
        .disposed(by: disposeBag)

    /* Prints:
     1) New initial value
    */
    
    variable.value = "1"

         // 5
         variable.asObservable()
             .subscribe {
                 print(label: "2)", event: $0)
             }
             .disposed(by: disposeBag)

         // 6
         variable.value = "2"
}


example(of: "ignoreElements") {
     
     // 1
     let strikes = PublishSubject<String>()
     let disposeBag = DisposeBag()
     
     // 2
     strikes
         .ignoreElements()
         .subscribe({ _ in
             print("You're out!")
         })
         .disposed(by: disposeBag)
     
     // 3
     strikes.onNext("X")
     strikes.onNext("X")
     strikes.onNext("X")
     
     // 4
     strikes.onCompleted()
    
    
 }

example(of: "elementAt") {
     
     // 1
     let strikes = PublishSubject<String>()
     let disposeBag = DisposeBag()
     
     // 2
     strikes
         .elementAt(2)
         .subscribe(onNext: { _ in
             print("You're out!")
         })
         .disposed(by: disposeBag)
     
     // 3
     strikes.onNext("X")
     strikes.onNext("X")
     strikes.onNext("X")
    
     
 }


example(of: "filter") {
    
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1,2,3,4,5,6)
        // 2
        .filter({ (int) -> Bool in
            int % 2 == 0
        })
        // 3
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}


example(of: "skip") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "B", "C", "D", "E", "F")
        // 2
        .skip(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}
example(of: "skipWhile") {
     //보험금 청구 앱을 개발한다고 가정해보자. 공제액이 충족될 때까지 보험금 지급을 거부하기 위해 skipWhile을 사용할 수 있다.
     let disposeBag = DisposeBag()
     
     // 1
     Observable.of(2, 2, 3, 4, 4)
         //2
         .skipWhile({ (int) -> Bool in
             int % 2 == 0
         })
         .subscribe(onNext: {
             print($0)
         })
         .disposed(by: disposeBag)
 }

example(of: "skipUntil") {
     
    let disposeBag = DisposeBag()
     
     // 1
     let subject = PublishSubject<String>()
     let trigger = PublishSubject<String>()
     
     // 2
     subject
         .skipUntil(trigger)
         .subscribe(onNext: {
             print($0)
         })
         .disposed(by: disposeBag)
     
     // 3
     subject.onNext("A")
     subject.onNext("B")
     
     // 4
     trigger.onNext("X")
     
     // 5
     subject.onNext("C")
 }

example(of: "take") {
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(1,2,3,4,5,6)
        // 2
        //RxSwift에서 어떤 요소를 취하고 싶을 때 사용할 수 있는 연산자는 take다.
        .take(3)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeWhile") {
    
    //방출된 요소의 index를 참고하고 싶은 경우가 있을 것이다. 이럴 때는 enumerated 연산자를 확인할 수 있다.
    
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of(2,2,4,4,6,6)
        // 2
        .enumerated()
        // 3
        .takeWhile({ index, value in
            // 4
            value % 2 == 0 && index < 3
        })
        // 5
        .map { $0.element }
        // 6
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "takeUntil") {
    let disposeBag = DisposeBag()
    
    // 1
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    // 2
    subject
        .takeUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    // 3
    subject.onNext("1")
    subject.onNext("2")
    
    // 4
    trigger.onNext("X")
    
    // 5
    subject.onNext("3")
}


example(of: "distincUntilChanged") {
    //그림에서처럼 `distinctUntilChanged`는 연달아 같은 값이 이어질 때 중복된 값을 막아주는 역할을 한다.
    
    // 매우 중요
    
    let disposeBag = DisposeBag()
    
    // 1
    Observable.of("A", "A", "B", "B", "A")
        //2
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}


let numberFormatter = NumberFormatter()
numberFormatter.numberStyle = .decimal
let price = 12345678
let result = numberFormatter.string(for: price)!

print(result)   //12,345,678


example(of: "distinctUntilChanged(_:)") {
    let disposeBag = DisposeBag()
    
    // 1
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    // 2
    Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
        // 3
        .distinctUntilChanged({ a, b in
            //4
            guard let aWords = formatter.string(from: a)?.components(separatedBy: " "),
                let bWords = formatter.string(from: b)?.components(separatedBy: " ") else {return false}
            
            var containsMatch = false
            
            // 5
            for aWord in aWords {
                for bWord in bWords {
                    if aWord == bWord {
                        containsMatch = true
                        break
                    }
                }
            }
            
            return containsMatch
        })
        // 6
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
}



/*
 전화번호 만들기
 
 input
   .skipWhile({ (number) -> Bool in
       number == 0
   })
   .filter({ (number) -> Bool in
       number < 10
   })
   .take(10)
   .toArray()
   .subscribe(onNext: {
       let phone = phoneNumber(from: $0)
       
       if let contact = contacts[phone] {
           print("Dialing \(contact) (\(phone))...")
       } else {
           print("Contact not found")
       }
   })
   .disposed(by: disposeBag)

 
 
 */


print("------------")

let numbers = Observable<Int>.create { observer in
    let start = getStartNumber()
    observer.onNext(start)
    observer.onNext(start+1)
    observer.onNext(start+2)
    observer.onCompleted()
    return Disposables.create()
}

var start = 0
 func getStartNumber() -> Int {
     start += 1
     return start
 }


numbers
     .subscribe(onNext: { el in
         
         print("element [\(el)]")
     }, onCompleted: {
         print("------------")
 })
numbers
     .subscribe(onNext: { el in
         
         print("element [\(el)]")
     }, onCompleted: {
         print("------------")
 })



example(of: "toArray") {
     let disposeBag = DisposeBag()
     
     // 1
     Observable.of("A", "B", "C")
         // 2
         .toArray()
        .subscribe({
             print($0)
         })
         .disposed(by: disposeBag)
         
     /* Prints:
         ["A", "B", "C"]
     */
 }


example(of: "map") {
     let disposeBag = DisposeBag()
     
     // 1
     let formatter = NumberFormatter()
     formatter.numberStyle = .spellOut
     
     // 2
     Observable<NSNumber>.of(123, 4, 9)
         // 3
         .map {
             formatter.string(from: $0) ?? ""
         }
         .subscribe(onNext: {
             print($0)
         })
         .disposed(by: disposeBag)
 }

example(of: "map") {
     let disposeBag = DisposeBag()
    
     // 2
     Observable<Int>.of(1,4,5,7, 9)
         // 3
         .enumerated()
         .map { index , interger in
            // ddd ? true : false
            index > 2 ? interger * 2: interger
         }
         .subscribe(onNext: {
             print($0)
         })
         .disposed(by: disposeBag)
 }

struct Student {
    var score: BehaviorSubject<Int>
}

// study 공부 필요 부분

example(of: "flatMap") {
    let disposeBag = DisposeBag()
    
    // 1
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    // 2
    let student = PublishSubject<Student>()
    
    // 3
    student
        .flatMap{
            $0.score
        }
        // 4
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
    
    // 5
    student.onNext(ryan)    // Printed: 80
    
    // 6
    ryan.score.onNext(85)   // Printed: 80 85
    
    // 7
    student.onNext(charlotte)   // Printed: 80 85 90
    
    // 8
    ryan.score.onNext(95)   // Printed: 80 85 90 95
    
    // 9
    charlotte.score.onNext(100) // Printed: 80 85 90 95 100
}


example(of: "flatMapLatest") {
    // flatMap에서의 코드와 다른 점은 단 하나, 변경된 ryan의 점수인 85가 여기서는 반영되지 않는다는 점이다.
    // 왜냐하면, flatMapLatest는 이미 charlotte의 최근 observable로 전환 했기 때문이다.
    
    let disposeBag = DisposeBag()
    
    let ryan = Student(score: BehaviorSubject(value: 80))
    let charlotte = Student(score: BehaviorSubject(value: 90))
    
    
    let student = PublishSubject<Student>()
    
    student
        .flatMapLatest{
            $0.score
        }
        .subscribe(
            onNext: {
                print($0)
            }
        ).disposed(by: disposeBag)
    
    student.onNext(ryan)
    ryan.score.onNext(85)
    
    student.onNext(charlotte)
    
    ryan.score.onNext(95)
    charlotte.score.onNext(100)
}


example(of: "materialize and dematerialize") {
     
     // 1
     enum MyError: Error {
         case anError
     }
     
     let disposeBag = DisposeBag()
     
     // 2
     let ryan = Student(score: BehaviorSubject(value: 80))
     let charlotte = Student(score: BehaviorSubject(value: 100))
     
     let student = BehaviorSubject(value: ryan)
     
     // 3
     let studentScore = student
         .flatMapLatest{
            $0.score.materialize()
     }
     
    
     // 4
     studentScore
         .subscribe(onNext: {
             print($0)
         })
         .disposed(by: disposeBag)
     
     // 5
     ryan.score.onNext(85)
     ryan.score.onError(MyError.anError)
     ryan.score.onNext(90)
     
     // 6
     student.onNext(charlotte)
     
     /* Prints:
         80
         85
         Unhandled error happened: anError
     */
 }


example(of: "materialize and dematerialize2") {
     
     // dematerialize를 이용하여 studentScore observable을 원래의 모양으로 리턴하고, 점수와 정지 이벤트를 방출할 수 있도록 한다.
     enum MyError: Error {
         case anError
     }
     
     let disposeBag = DisposeBag()
     
     // 2
     let ryan = Student(score: BehaviorSubject(value: 80))
     let charlotte = Student(score: BehaviorSubject(value: 100))
     
     let student = BehaviorSubject(value: ryan)
     
     // 3
     let studentScore = student
         .flatMapLatest{
            $0.score.materialize()
     }
     
    
     // 4
    studentScore
             // 1
             .filter {
                 guard $0.error == nil else {
                     print($0.error!)
                     return false
                 }
                 
                 return true
             }
             // 2
             .dematerialize()
             .subscribe(onNext: {
                 print($0)
             })
             .disposed(by: disposeBag)
             
     // 5
     ryan.score.onNext(85)
     ryan.score.onError(MyError.anError)
     ryan.score.onNext(90)
     
     // 6
     student.onNext(charlotte)
     
     /* Prints:
         80
         85
         Unhandled error happened: anError
     */
 }

example(of: "startWith") {
    // 1
    let numbers = Observable.of(2, 3, 4)

    // 2
    let observable = numbers.startWith(1)
    observable.subscribe(onNext: {
        print($0)
    })

    /* Prints:
     1
     2
     3
     4
    */
}


example(of: "Observable.concat") {
    // 1
    
    let first = Observable.of(1, 2, 3)
    let second = Observable.of(4, 5, 6)

    // 2
    //Observable.concat(_:)을 통해서는 두개의 sequence를 묶을 수 있다.
    let observable = Observable.concat([first, second])

    observable.subscribe(onNext: {
        print($0)
    })

    /* Prints:
     1
     2
     3
     4
     5
     6
    */
}
example(of: "concat") {
    let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")

    let observable = germanCities.concat(spanishCities)
    observable.subscribe(onNext: { print($0) })
}

example(of: "concatMap") {
    // 1
    let sequences = ["Germany": Observable.of("Berlin", "Münich", "Frankfurt"),
                     "Spain": Observable.of("Madrid", "Barcelona", "Valencia")]

    // 2/
    //concatMap은 각각의 sequence가 다음 sequence가 구독되기 전에 합쳐진다는 것을 보증한다.
    let observable = Observable.of("Germany", "Spain")
        .concatMap({ country in
            sequences[country] ?? .empty() })

    // 3
    _ = observable.subscribe(onNext: {
        print($0)
    })
}


example(of: "merge") {
    // 1
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()

    // 2
    let source = Observable.of(left.asObservable(), right.asObservable())

    // 3
    let observable = source.merge()
    let disposable = observable.subscribe(onNext: {
        print($0)
    })

    // 4
    var leftValues = ["Berlin", "Münich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    
    repeat {
        if arc4random_uniform(2) == 0 {
            if !leftValues.isEmpty {
                left.onNext("Left :" + leftValues.removeFirst())
            }
        } else if !rightValues.isEmpty {
            right.onNext("right :" + rightValues.removeFirst())
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty

    // 5
    disposable.dispose()
}



example(of: "combineLast") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()

    // 1
    let observable = Observable.combineLatest(left, right, resultSelector: { lastLeft, lastRight in
        "\(lastLeft) \(lastRight)"
    })

    let disposable = observable.subscribe(onNext: {
        print($0)
    })

    // 2
    print("> Sending a value to Left")
    left.onNext("Hello,")
    print("> Sending a value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    print("> Sending another value to Left")
    left.onNext("Have a good day,")

    // 3
    disposable.dispose()

    /* Prints:
     > Sending a value to Left
     > Sending a value to Right
     Hello, world
     > Sending another value to Right
     Hello, RxSwift
     > Sending another value to Left
     Have a good day, RxSwift
    */
}
example(of: "combine user choice and value") {
    
    let choice:Observable<DateFormatter.Style> = Observable.of(.short, .long)
    let dates = Observable.of(Date())
   
    let observable = Observable.combineLatest(choice, dates, resultSelector: { (format, when) -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    })
   
    observable.subscribe(onNext: { print($0) })
}


example(of: "zip") {

     // 1
     enum Weatehr {
         case cloudy
         case sunny
     }

     let left:Observable<Weatehr> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
     let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")

     // 2
    //zip(_:_:resultSelector:)은 다음과 같이 동작한다.
    //제공한 observable을 구독한다.
    //각각의 observable이 새 값을 방출하길 기다린다.
    //각각의 새 값으로 클로저를 호출한다.
    //상기 코드에서 Vienna가 출력되지 않은 것을 알 수 있다. 왜일까?
    //이 것은 zip계열 연산자의 특징이다.
    //이들은 일련의 observable이 새 값을 각자 방출할 때까지 기다리다가, 둘 중 하나의 observable이라도 완료되면, zip 역시 완료된다.
    // 더 긴 observable이 남아있어도 기다리지 않는 것이다. 이렇게 sequence에 따라 단계별로 작동하는 방법을 가르켜 indexed sequencing 이라고 한다.
     let observable = Observable.zip(left, right, resultSelector: { (weather, city) in
         return "It's \(weather) in \(city)"
     })

     observable.subscribe(onNext: {
         print($0)
     })

     /* Prints:
      It's sunny in Lisbon
      It's cloudy in Copenhagen
      It's cloudy in London
      It's sunny in Madrid
      */
 }

example(of: "withLatestFrom") {
    // 1
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()

    // 2
    let observable = button.withLatestFrom(textField)
    _ = observable.subscribe(onNext: { print($0) })

    // 3
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    button.onNext(())
    button.onNext(())
}


example(of: "amb") {
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()

    // 1
    //amb(_:) 연산자는 left, right 두 개 모두의 observable을 구독한다. 그리고 두 개중 어떤 것이든 요소를 모두 방출하는 것을 기다리다가 하나가 방출을 시작하면 나머지에 대해서는 구독을 중단한다. 그리고 처음 작동한 observable에 대해서만 요소들을 늘어놓는다.
    

    let observable = left.amb(right)
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })

    // 2
    right.onNext("Copenhagen")
    left.onNext("Lisbon")
    
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")

    disposable.dispose()
}



example(of: "switchLatest") {
    // 1
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()

    let source = PublishSubject<Observable<String>>()

    // 2
    let observable = source.switchLatest()
    let disposable = observable.subscribe(onNext: { print($0) })

    // 3
    source.onNext(one)
    one.onNext("Some text from sequence one")
    two.onNext("Some text from sequence two")

    source.onNext(two)
    two.onNext("More text from sequence two")
    one.onNext("and also from sequence one")

    source.onNext(three)
    two.onNext("Why don't you see me?")
    one.onNext("I'm alone, help me")
    three.onNext("Hey it's three. I win")

    source.onNext(one)
    one.onNext("Nope. It's me, one!")

    disposable.dispose()

    /* Prints:
     Some text from sequence one
     More text from sequence two
     Hey it's three. I win
     Nope. It's me, one!
     */
}


example(of: "reduce") {
    let source = Observable.of(1, 3, 5, 7, 9)

    // 1
    let observable = source.reduce(0, accumulator: +)
    observable.subscribe(onNext: { print($0) } )

    // 주석 1은 다음과 같은 의미다.
    // 2
    let observable2 = source.reduce(0, accumulator: { summary, newValue in
        return summary + newValue
    })
    observable2.subscribe(onNext: { print($0) })
}


example(of: "scan") {
     let source = Observable.of(1, 3, 5, 7, 9)

     let observable = source.scan(0, accumulator: +)
     observable.subscribe(onNext: { print($0) })

     /* Prints:
      scan(_:accumulator:)의 쓰임은 광범위 하다. 총합, 통계, 상태를 계산할 때 등 다양하게 쓸 수 있다.
      1
      4
      9
      16
      25
     */
 }
example(of: "Challenge 1") {
    let source = Observable.of(1, 3, 5, 7, 9)
    let observable = source.scan(0, accumulator: +)

    let _ = Observable.zip(source, observable, resultSelector: { (current, total) in
        return "\(current) \(total)"
    })
        .subscribe(onNext: { print($0) })
}
example(of: "Challenge 2") {
    let source = Observable.of(1, 3, 5, 7, 9)
    let observable = source.scan((0,0), accumulator: { (current, total) in
        return (total, current.1 + total)
    })
        .subscribe(onNext: { tuple in
            print("\(tuple.0) \(tuple.1)")
        })
}


// MARK:- model struct of user

struct User: Codable {
    var name: String
    var age: Int
}

// MARK:- json encode and decode

do {
    let user = User(name: "Hohyeon", age: 22)
    let encoder = JSONEncoder()
    let data = try encoder.encode(user)
    
    let decoder = JSONDecoder()
    let secondUser = try decoder.decode(User.self, from: data)
    
    print(secondUser)

} catch {
    print("Whoops, I did it again: \(error)")
}


let closureValue = { (name:String) in print(name) }

let closureFunc = { (name:String) in print(name) }

closureValue("hello")

closureFunc("world")

let g = { (a:Int,b:Int) in print("sum = \(a+b)") }

g(1,2)


func chooseStepFunction(backward: Bool) -> (Int) -> Int {
    func stepForward(input: Int) -> Int { return input + 1 }
    func stepBackward(input: Int) -> Int { return input - 1 }
    
    return backward ? stepBackward: stepForward
}


