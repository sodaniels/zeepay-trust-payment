//
//  KIFTestActor.swift
//  ExampleTests
//

extension KIFTestActor {
    func tester(file: String = #file, _ line: Int = #line) -> KIFUITestActor {
        KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    func system(file: String = #file, _ line: Int = #line) -> KIFSystemTestActor {
        KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}
