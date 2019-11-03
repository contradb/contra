import namor from "namor"

const range = len => {
  const arr = []
  for (let i = 0; i < len; i++) {
    arr.push(i)
  }
  return arr
}

const newDance = () => {
  const statusChance = Math.random()
  return {
    title: namor.generate({ words: 1, numbers: 0 }),
    choreographer: namor.generate({ words: 2, numbers: 0 }),
    hook: namor.generate({ words: 3, numbers: 0 }),
    formation: "improper",
    user: namor.generate({ words: 2, numbers: 0 }),
    entered: namor.generate({ numbers: 1 }),
    updated: namor.generate({ numbers: 1 }),
    sharing: "everyone",
    figures: "whole dance",
  }
}

export default function makeData(...lens) {
  const makeDataLevel = (depth = 0) => {
    const len = lens[depth]
    return range(len).map(d => {
      return {
        ...newDance(),
        subRows: lens[depth + 1] ? makeDataLevel(depth + 1) : undefined,
      }
    })
  }

  return makeDataLevel()
}
