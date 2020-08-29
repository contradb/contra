import useBreakpoint from "use-breakpoint"

export enum Breakpoint {
  Xs = 109,
  Sm = 209,
  Md = 309,
  Lg = 409,
}

type BreakpointName = "xs" | "sm" | "md" | "lg"

const bootstrap3Resolutions: Record<BreakpointName, number> = {
  xs: 0,
  sm: 768,
  md: 992,
  lg: 1200,
}

const enumMap: Record<BreakpointName, Breakpoint> = {
  xs: Breakpoint.Xs,
  sm: Breakpoint.Sm,
  md: Breakpoint.Md,
  lg: Breakpoint.Lg,
}

export const useBootstrap3Breakpoint = (): Breakpoint =>
  enumMap[useBreakpoint(bootstrap3Resolutions, "xs").breakpoint]

export default useBootstrap3Breakpoint
