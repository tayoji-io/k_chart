class TechnicalindicatorJs {
  static var kdj = '''
function calcHnLn (dataList = []) {
  let hn = Number.MIN_SAFE_INTEGER
  let ln = Number.MAX_SAFE_INTEGER
  dataList.forEach(data => {
    hn = Math.max(data.high, hn)
    ln = Math.min(data.low, ln)
  })
  return { hn, ln }
}
export default {
  name: 'KDJ',
  shortName: 'KDJ',
  calcParams: [9, 3, 3],
  plots: [
    { key: 'k', title: 'K: ', type: 'line' },
    { key: 'd', title: 'D: ', type: 'line' },
    { key: 'j', title: 'J: ', type: 'line' }
  ],
  calcTechnicalIndicator: (dataList,{params}) => {
    const result = []
    dataList.forEach((kLineData, i) => {
      const kdj = {}
      const close = kLineData.close
      if (i >= params[0] - 1) {
        const lhn = calcHnLn(dataList.slice(i - (params[0] - 1), i + 1))
        const ln = lhn.ln
        const hn = lhn.hn
        const hnSubLn = hn - ln
        const rsv = (close - ln) / (hnSubLn === 0 ? 1 : hnSubLn) * 100
        kdj.k = ((params[1] - 1) * (result[i - 1].k || 50) + rsv) / params[1]
        kdj.d = ((params[2] - 1) * (result[i - 1].d || 50) + kdj.k) / params[2]
        kdj.j = 3.0 * kdj.k - 2.0 * kdj.d
      }
      result.push(kdj)
    })
    return result
  }
}
''';

  static var vol = '''

export default {
  name: 'VOL',
  shortName: 'VOL',
  series: 'volume',
  calcParams: [5, 10, 20],
  shouldCheckParamCount: false,
  shouldFormatBigNumber: true,
  precision: 0,
  minValue: 0,
  plots: [
    { key: 'ma5', title: 'MA5: ', type: 'line' },
    { key: 'ma10', title: 'MA10: ', type: 'line' },
    { key: 'ma20', title: 'MA20: ', type: 'line' },
    {
      key: 'volume',
      title: 'VOLUME: ',
      type: 'bar',
      baseValue: 0,
      color: 2
    }
  ],
  regeneratePlots: (params) => {
    const plots = params.map(p => {
      return { key: `ma\${p}`, title: `MA\${p}: `, type: 'line' }
    })
    plots.push({
      key: 'volume',
      title: 'VOLUME: ',
      type: 'bar',
      baseValue: 0,
      color: 2
    })
    return plots
  },
  calcTechnicalIndicator: (dataList, { params, plots }) => {
    const volSums = []
    return dataList.map((kLineData, i) => {
      const volume = kLineData.volume || 0
      const vol = { volume }
      params.forEach((p, index) => {
        volSums[index] = (volSums[index] || 0) + volume
        if (i >= p - 1) {
          vol[plots[index].key] = volSums[index] / p
          volSums[index] -= dataList[i - (p - 1)].volume
        }
      })
      return vol
    })
  }
}

''';

  static var macd = '''
export default {
  name: 'MACD',
  shortName: 'MACD',
  calcParams: [12, 26, 9],
  plots: [
    { key: 'dif', title: 'DIF: ', type: 'line' },
    { key: 'dea', title: 'DEA: ', type: 'line' },
    {
      key: 'macd',
      title: 'MACD: ',
      type: 'bar',
      baseValue: 0,
      color: 0,
      stroke: 0
    }
  ],
  calcTechnicalIndicator: (dataList, { params }) => {
    let closeSum = 0
    let emaShort
    let emaLong
    let dif = 0
    let difSum = 0
    let dea = 0
    const maxPeriod = Math.max(params[0], params[1])
    return dataList.map((kLineData, i) => {
      const macd = {}
      const close = kLineData.close
      closeSum += close
      if (i >= params[0] - 1) {
        if (i > params[0] - 1) {
          emaShort = (2 * close + (params[0] - 1) * emaShort) / (params[0] + 1)
        } else {
          emaShort = closeSum / params[0]
        }
      }
      if (i >= params[1] - 1) {
        if (i > params[1] - 1) {
          emaLong = (2 * close + (params[1] - 1) * emaLong) / (params[1] + 1)
        } else {
          emaLong = closeSum / params[1]
        }
      }
      if (i >= maxPeriod - 1) {
        dif = emaShort - emaLong
        macd.dif = dif
        difSum += dif
        if (i >= maxPeriod + params[2] - 2) {
          if (i > maxPeriod + params[2] - 2) {
            dea = (dif * 2 + dea * (params[2] - 1)) / (params[2] + 1)
          } else {
            dea = difSum / params[2]
          }
          macd.macd = (dif - dea) * 2
          macd.dea = dea
        }
      }
      return macd
    })
  }
}
''';

  static var ma = '''
export default {
  name: 'MA',
  shortName: 'MA',
  series: 'price',
  calcParams: [5, 10, 30, 60],
  precision: 2,
  shouldCheckParamCount: false,
  shouldOhlc: true,
  plots: [
    { key: 'ma5', title: 'MA5: ', type: 'line' },
    { key: 'ma10', title: 'MA10: ', type: 'line' },
    { key: 'ma30', title: 'MA30: ', type: 'line' },
    { key: 'ma60', title: 'MA60: ', type: 'line' }
  ],
  regeneratePlots: (params) => {
    return params.map(p => {
      return { key: `ma\${p}`, title: `MA\${p}: `, type: 'line' }
    })
  },
  calcTechnicalIndicator: (dataList, { params, plots }) => {
    const closeSums = []
    return dataList.map((kLineData, i) => {
      const ma = {}
      const close = kLineData.close
      params.forEach((p, index) => {
        closeSums[index] = (closeSums[index] || 0) + close
        if (i >= p - 1) {
          ma[plots[index].key] = closeSums[index] / p
          closeSums[index] -= dataList[i - (p - 1)].close
        }
      })
      return ma
    })
  }
}

''';

  static var bbi = '''
export default {
  name: 'BBI',
  shortName: 'BBI',
  series: 'price',
  precision: 2,
  calcParams: [3, 6, 12, 24],
  shouldCheckParamCount: true,
  shouldOhlc: true,
  plots: [
    { key: 'bbi', title: 'BBI: ', type: 'line' }
  ],
  calcTechnicalIndicator: (dataList, { params }) => {
    const maxPeriod = Math.max.apply(null, params)
    const closeSums = []
    const mas = []
    return dataList.map((kLineData, i) => {
      const bbi = {}
      const close = kLineData.close
      params.forEach((p, index) => {
        closeSums[index] = (closeSums[index] || 0) + close
        if (i >= p - 1) {
          mas[index] = closeSums[index] / p
          closeSums[index] -= dataList[i - (p - 1)].close
        }
      })
      if (i >= maxPeriod - 1) {
        let maSum = 0
        mas.forEach(ma => {
          maSum += ma
        })
        bbi.bbi = maSum / 4
      }
      return bbi
    })
  }
}

''';

  static var ema = '''
export default {
  name: 'EMA',
  shortName: 'EMA',
  series: 'price',
  calcParams: [6, 12, 20],
  precision: 2,
  shouldCheckParamCount: false,
  shouldOhlc: true,
  plots: [
    { key: 'ema6', title: 'EMA6: ', type: 'line' },
    { key: 'ema12', title: 'EMA12: ', type: 'line' },
    { key: 'ema20', title: 'EMA20: ', type: 'line' }
  ],
  regeneratePlots: (params) => {
    return params.map(p => {
      return { key: `ema\${p}`, title: `EMA\${p}: `, type: 'line' }
    })
  },
  calcTechnicalIndicator: (dataList, { params, plots }) => {
    let closeSum = 0
    const emaValues = []
    return dataList.map((kLineData, i) => {
      const ema = {}
      const close = kLineData.close
      closeSum += close
      params.forEach((p, index) => {
        if (i >= p - 1) {
          if (i > p - 1) {
            emaValues[index] = (2 * close + (p - 1) * emaValues[index]) / (p + 1)
          } else {
            emaValues[index] = closeSum / p
          }
          ema[plots[index].key] = emaValues[index]
        }
      })
      return ema
    })
  }
}
''';

  static var sma = '''
export default {
  name: 'SMA',
  shortName: 'SMA',
  series: 'price',
  calcParams: [12, 2],
  precision: 2,
  plots: [
    { key: 'sma', title: 'SMA: ', type: 'line' }
  ],
  shouldCheckParamCount: true,
  shouldOhlc: true,
  calcTechnicalIndicator: (kLineDataList, { params }) => {
    let closeSum = 0
    let smaValue = 0
    return kLineDataList.map((kLineData, i) => {
      const sma = {}
      const close = kLineData.close
      closeSum += close
      if (i >= params[0] - 1) {
        if (i > params[0] - 1) {
          smaValue = (close * params[1] + smaValue * (params[0] - params[1] + 1)) / (params[0] + 1)
        } else {
          smaValue = closeSum / params[0]
        }
        sma.sma = smaValue
      }
      return sma
    })
  }
}
''';

  static var boll = '''
function getBollMd (dataList, ma) {
  const dataSize = dataList.length
  let sum = 0
  dataList.forEach(data => {
    const closeMa = data.close - ma
    sum += closeMa * closeMa
  })
  const b = sum > 0
  sum = Math.abs(sum)
  const md = Math.sqrt(sum / dataSize)
  return b ? md : -1 * md
}
export default {
  name: 'BOLL',
  shortName: 'BOLL',
  series: 'price',
  calcParams: [20, { value: 2, allowDecimal: true }],
  precision: 2,
  shouldOhlc: true,
  plots: [
    { key: 'up', title: 'UP: ', type: 'line' },
    { key: 'mid', title: 'MID: ', type: 'line' },
    { key: 'dn', title: 'DN: ', type: 'line' }
  ],
  calcTechnicalIndicator: (dataList, { params }) => {
    const p = params[0] - 1
    let closeSum = 0
    return dataList.map((kLineData, i) => {
      const close = kLineData.close
      const boll = {}
      closeSum += close
      if (i >= p) {
        boll.mid = closeSum / params[0]
        const md = getBollMd(dataList.slice(i - p, i + 1), boll.mid)
        boll.up = boll.mid + params[1] * md
        boll.dn = boll.mid - params[1] * md
        closeSum -= dataList[i - p].close
      }
      return boll
    })
  }
}

''';
  static var sar = '''
export default {
  name: 'SAR',
  shortName: 'SAR',
  series: 'price',
  calcParams: [2, 2, 20],
  precision: 2,
  shouldOhlc: true,
  plots: [
    {
      key: 'sar',
      title: 'SAR: ',
      type: 'circle',
      color: 3
    }
  ],
  calcTechnicalIndicator: (dataList, { params }) => {
    const startAf = params[0] / 100
    const step = params[1] / 100
    const maxAf = params[2] / 100

    // 加速因子
    let af = startAf
    // 极值
    let ep = -100
    // 判断是上涨还是下跌  false：下跌
    let isIncreasing = false
    let sar = 0
    return dataList.map((kLineData, i) => {
      // 上一个周期的sar
      const preSar = sar
      const high = kLineData.high
      const low = kLineData.low
      if (isIncreasing) {
        // 上涨
        if (ep === -100 || ep < high) {
          // 重新初始化值
          ep = high
          af = Math.min(af + step, maxAf)
        }
        sar = preSar + af * (ep - preSar)
        const lowMin = Math.min(dataList[Math.max(1, i) - 1].low, low)
        if (sar > kLineData.low) {
          sar = ep
          // 重新初始化值
          af = startAf
          ep = -100
          isIncreasing = !isIncreasing
        } else if (sar > lowMin) {
          sar = lowMin
        }
      } else {
        if (ep === -100 || ep > low) {
          // 重新初始化值
          ep = low
          af = Math.min(af + step, maxAf)
        }
        sar = preSar + af * (ep - preSar)
        const highMax = Math.max(dataList[Math.max(1, i) - 1].high, high)
        if (sar < kLineData.high) {
          sar = ep
          // 重新初始化值
          af = 0
          ep = -100
          isIncreasing = !isIncreasing
        } else if (sar < highMax) {
          sar = highMax
        }
      }
      return { sar }
    })
  }
}

''';
  static var mda = '''
export default {
  name: 'DMA',
  shortName: 'DMA',
  calcParams: [10, 50, 10],
  plots: [
    { key: 'dma', title: 'DMA: ', type: 'line' },
    { key: 'ama', title: 'AMA: ', type: 'line' }
  ],
  calcTechnicalIndicator: (dataList, { params }) => {
    const maxPeriod = Math.max(params[0], params[1])
    let closeSum1 = 0
    let closeSum2 = 0
    let dmaSum = 0
    const result = []
    dataList.forEach((kLineData, i) => {
      const dma = {}
      const close = kLineData.close
      closeSum1 += close
      closeSum2 += close
      let ma1
      let ma2
      if (i >= params[0] - 1) {
        ma1 = closeSum1 / params[0]
        closeSum1 -= dataList[i - (params[0] - 1)].close
      }
      if (i >= params[1] - 1) {
        ma2 = closeSum2 / params[1]
        closeSum2 -= dataList[i - (params[1] - 1)].close
      }

      if (i >= maxPeriod - 1) {
        const dif = ma1 - ma2
        dma.dma = dif
        dmaSum += dif
        if (i >= maxPeriod + params[2] - 2) {
          dma.ama = dmaSum / params[2]
          dmaSum -= result[i - (params[2] - 1)].dma
        }
      }
      result.push(dma)
    })
    return result
  }
}

''';
}
