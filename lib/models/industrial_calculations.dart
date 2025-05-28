class IndustrialCalculations {
  // [1] 距離[mm]から距離[m]を計算
  static double calculateDistanceM({required double distanceMm}) {
    // 距離(m) = 距離(mm) / 1000
    return distanceMm / 1000;
  }

  // [2] 到達時間[Sec]から到達時間[min]を計算
  static double calculateArrivalTimeMin({required double arrivalTimeSec}) {
    // 到達時間(min) = 到達時間(Sec) / 60
    return arrivalTimeSec / 60;
  }

  // [3] 距離[m]と到達時間[min]からT速度を計算
  static double calculateTSpeed({required double distanceM, required double arrivalTimeMin}) {
    // T速度(m/rpm/min) = 距離(m) / 到達時間(min)
    return distanceM / arrivalTimeMin;
  }

  // [4] ターンテーブル[P.C.D]から円周を計算
  static double calculateCircumference({required double pcd}) {
    // 円周(mm) = ターンテーブルP.C.D * π
    return pcd * 3.14;
  }

  // [5] 各モータ定格回転数、T速度、円周から計算上の減速比を計算
  static double calculateReductionRatio({
    required double ratedRpm, 
    required double tSpeed, 
    required double circumference
  }) {
    // 計算上の減速比 = 各モータ定格回転数 / (T速度 * 1000 / 円周)
    return ratedRpm / (tSpeed * 1000 / circumference);
  }

  // [6] 各モータ定格回転数と減速比から回転数を計算
  static double calculateMotorRpm({required double ratedRpm, required double reductionRatio}) {
    // 回転数(rpm/min) = 各モータ定格回転数 / 減速比
    return ratedRpm / reductionRatio;
  }

  // [7] 回転数からHz換算を計算
  static double calculateHzFromRpm({required double rpm}) {
    // 回転数(1Hz/rpm) = 回転数(rpm/min) / 50
    return rpm / 50;
  }

  // [8] 円周と回転数から回転数(m/min)を計算
  static double calculateRpmToMeterPerMin({required double circumference, required double rpm}) {
    // 回転数(m/min) = 円周(mm) * 回転数(rpm/min) / 1000
    return circumference * rpm / 1000;
  }

  // [9] 能力本数から処理能力を計算
  static double calculateProcessingTime({required double bottlesPerMinute}) {
    // 処理能力(Sec) = 60 / 能力本数
    return 60 / bottlesPerMinute;
  }

  // [10] ボトル間隔と能力本数から速度を計算
  static double calculateSpeed({required double bottleSpacing, required double bottlesPerMinute}) {
    // 速度(m/min) = ボトル間隔(mm) * 能力本数 / 1000
    return bottleSpacing * bottlesPerMinute / 1000;
  }

  // [11] 処理能力本数と処理能力から処理能力を計算
  static double calculateTotalProcessingTime({required double numberOfBottles, required double processingTimePerBottle}) {
    // 処理能力(秒) = 処理能力本数(本) * 処理能力(Sec)
    return numberOfBottles * processingTimePerBottle;
  }

  // [12] T速度、円周、回転数からインバータを計算
  static double calculateInverter({
    required double tSpeed, 
    required double circumference, 
    required double hzRpm
  }) {
    // インバータ(Hz) = (T速度 * 1000 / 円周) / 回転数(1Hz/rpm)
    return (tSpeed * 1000 / circumference) / hzRpm;
  }

  // [13] 変則的速度と円周から変則的速度(Hz)を計算
  static double calculateIrregularSpeedHz({required double speed, required double circumference}) {
    // 変則的速度(Hz) = 変則的速度 * 1000 / 円周(mm)
    return speed * 1000 / circumference;
  }

  // [14] 変則的速度[Hz]と回転数[1Hz/rpm]からインバータ[Hz]を計算
  static double calculateIrregularSpeedInverter({required double irregularSpeedHz, required double hzRpm}) {
    // インバータ(Hz) = 変則的速度(Hz) / 回転数(1Hz/rpm)
    return irregularSpeedHz / hzRpm;
  }
} 