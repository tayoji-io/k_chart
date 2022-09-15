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
