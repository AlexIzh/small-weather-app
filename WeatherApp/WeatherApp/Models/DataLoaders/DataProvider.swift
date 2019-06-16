//
//  DataProvider.swift
//  WeatherApp
//
//  Created by Alex Severyanov on 6/13/19.
//  Copyright © 2019 Alex Severyanov. All rights reserved.
//

import Foundation

class DataProvider {
   let session: Session
   let responseQueue: DispatchQueue?

   private var tasks: [WeakURLTask] = []

   init(session: Session, responseQueue: DispatchQueue?) {
      self.session = session
      self.responseQueue = responseQueue
   }

   deinit {
      cancelAll()
   }
}

extension DataProvider {
   @discardableResult
   func startRequest(for api: API, completion: @escaping (Result<Data, Error>) -> Void) -> URLTask? {
      guard let request = api.makeRequest() else { return nil }

      let task = session.task(with: request, completion: completion)
      task.resume()
      tasks.append(WeakURLTask(task))
      return task
   }

   func cancelAll() {
      tasks.forEach { $0.cancel() }
      tasks.removeAll()
   }
}

func execute(on queue: DispatchQueue?, closure: @escaping () -> Void) {
   queue?.async(execute: closure) ?? closure()
}

private class WeakURLTask {

   private weak var task: URLTask?

   init(_ task: URLTask) {
      self.task = task
   }

   func cancel() {
      task?.cancel()
   }
}
