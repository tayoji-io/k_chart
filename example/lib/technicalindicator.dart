var kdj = '''
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

var vol = '''

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

var macd = '''
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

var ma = '''
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
