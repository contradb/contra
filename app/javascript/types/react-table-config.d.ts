declare module "react-table"
// import {
//   UseColumnOrderInstanceProps,
//   UseColumnOrderState,
//   UseExpandedInstanceProps,
//   UseExpandedOptions,
//   UseExpandedRowProps,
//   UseExpandedState,
//   UseFiltersColumnOptions,
//   UseFiltersColumnProps,
//   UseFiltersInstanceProps,
//   UseFiltersOptions,
//   UseFiltersState,
//   UseGroupByCellProps,
//   UseGroupByColumnOptions,
//   UseGroupByColumnProps,
//   UseGroupByInstanceProps,
//   UseGroupByOptions,
//   UseGroupByRowProps,
//   UseGroupByState,
//   UsePaginationInstanceProps,
//   UsePaginationOptions,
//   UsePaginationState,
//   UseResizeColumnsColumnOptions,
//   UseResizeColumnsHeaderProps,
//   UseResizeColumnsOptions,
//   UseRowSelectInstanceProps,
//   UseRowSelectOptions,
//   UseRowSelectRowProps,
//   UseRowSelectState,
//   UseRowStateCellProps,
//   UseRowStateInstanceProps,
//   UseRowStateRowProps,
//   UseSortByColumnOptions,
//   UseSortByColumnProps,
//   UseSortByInstanceProps,
//   UseSortByOptions,
//   UseSortByState,
//   UseTableCellProps,
// } from "react-table"
// import {} from "react-table"

// declare module "react-table" {
//   // take this file as-is, or comment out the sections that don't apply to your plugin configuration

//   export interface TableOptions<D extends object>  // UseExpandedOptions<D>, // UseFiltersOptions<D>, // UseGroupByOptions<D>, // UsePaginationOptions<D>, // UseRowSelectOptions<D>, // UseSortByOptions<D>,
//     extends // UseFiltersOptions<D>,
//   // UseResizeColumnsOptions<D>,
//   // note that having Record here allows you to add anything to the options, this matches the spirit of the
//   // underlying js library, but might be cleaner if it's replaced by a more specific type that matches your
//   // feature set, this is a safe default.
//   Record<string, any> {}

//   export interface TableInstance<D extends object = {}> {}
//   // UseColumnOrderInstanceProps<D>,
//   // UseExpandedInstanceProps<D>,
//   // UseFiltersInstanceProps<D>,
//   // UseGroupByInstanceProps<D>,
//   // UsePaginationInstanceProps<D>,
//   // UseRowSelectInstanceProps<D>,
//   // UseRowStateInstanceProps<D>,
//   // UseSortByInstanceProps<D>

//   export interface TableState<D extends object = {}>
//     extends UseSortByState<D> {}
//   // UseGroupByState<D>,
//   // UseFiltersState<D>,
//   // UseExpandedState<D>,
//   // UseColumnOrderState<D>,
//   // UsePaginationState<D>,
//   // UseRowSelectState<D>

//   export interface Column<D extends object = {}> {}
//   // UseFiltersColumnOptions<D>,
//   // UseGroupByColumnOptions<D>,
//   // UseSortByColumnOptions<D>,
//   // UseResizeColumnsColumnOptions<D> {}

//   export interface ColumnInstance<D extends object = {}>
//     extends UseSortByColumnProps<D> {}
//   // UseFiltersColumnProps<D>,
//   // UseGroupByColumnProps<D>,
//   // UseResizeColumnsHeaderProps<D>,

//   export interface Cell<D extends object = {}> {}
//   // UseTableCellProps<D>,
//   // UseGroupByCellProps<D>,
//   // UseRowStateCellProps<D> {}

//   export interface Row<D extends object = {}> {}
//   // UseExpandedRowProps<D>,
//   // UseGroupByRowProps<D>,
//   // UseRowSelectRowProps<D>,
//   // UseRowStateRowProps<D> {}
// }
