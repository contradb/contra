import { Program } from "../models/program"

const url = "/api/v1/programs"
const headers = { "Content-type": "application/json" }

export const webApi = {
  savePrograms: async (programs: Program[]): Promise<void> => {
    const body = JSON.stringify({ programs: programs })
    const response = await fetch(url, { method: "POST", headers, body })
    console.log("ahoy", programs)
    if (response.ok) return Promise.resolve(undefined)
    else return Promise.reject("Crushing failure")
  },
}
