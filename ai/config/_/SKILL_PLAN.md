# Plan mode skill

Goal: create skills to enhance planning / specification before creating.
Requirements:
 - Format: markdown in the project.
 - When to use: in plan mode, when the problem becomes complex, need multiple sessions for instance.
 - Folder organisation:
   - specs/<NAME>/: the root of a session / feature / architecture
     - ./studies/<NAME>.md: studies created during research, to prepare the SYSTEM_DESIGN.md to justify decisions. The SYSTEM_DESIGN must reference studies when the FR/NFR need a dedicated study to remove uncertainty.
     - ./SYSTEM_DESIGN.md: the markdown containing architecture, analysis. A dedicated study should be made to explain and list action regarding a good and simple system design (ref: [an example used during interview to use as seed to find out relevant references](https://github.com/donnemartin/system-design-primer)
     - ./TASKS.md: the task list, created right after functional and non functional requirements to organize the work, ask question / clarify in details. Each question / change / knowledge must be tracked back in the SYSTEM_DESIGN.md to adjust the plan.

Overhall, I want to analyze the state of the art about simple and efficient plannification to avoid reinventing the wheel. If it is the case, I want to compare both approach, the one I have defined vs proposed approach.