//
//  WeatherImageProviderTests.swift
//  WeatherAppTests
//
//  Created by Alex Severyanov on 6/13/19.
//  Copyright © 2019 Alex Severyanov. All rights reserved.
//

import XCTest
@testable import WeatherApp

class WeatherImageProviderTests: XCTestCase {
   func testLoad_success() throws  {
      let url = Bundle(for: type(of: self)).url(forResource: "10d", withExtension: "png")!
      let data = try Data(contentsOf: url)
      let session = DataProviderTests.TestSession()
      session.stubbedTaskCompletionParams = .success(data)
      let loader = WeatherImageProvider(session: session, responseQueue: nil)
      var isLoadedImage = false

      loader.load(id: "1") {
         isLoadedImage = (try? $0.get()) != nil
      }

      Assert.isTrue(isLoadedImage)
      if case WeatherAPI.image(let id)? = session.invokedTaskParam, id == "1" {} else {
         Assert.fail(String(describing: session.invokedTaskParam))
      }
   }

   func testLoad_invalidData() {
      let session = DataProviderTests.TestSession()
      session.stubbedTaskCompletionParams = .success(Data())
      let loader = WeatherImageProvider(session: session, responseQueue: nil)
      var isCompletionCalled = false


      loader.load(id: "1") {
         isCompletionCalled = true
         if case .failure(let error as WeatherImageProvider.Error) = $0, error == .invalidData {
         } else {
            Assert.fail(String(describing: $0))
         }
      }

      Assert.isTrue(isCompletionCalled)
   }
}
