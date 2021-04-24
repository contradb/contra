import { ProgramEditorDragDropContext } from "../components/program-editor-drag-drop-context";
import { Activity } from "./activity";

export interface Program {
  title: string
  id?: number
  activities: Array<Activity>  
};
