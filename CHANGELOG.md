# Changelog

## [b69c1f6](https://github.com/xronos-inc/xronos-dashboard/tree/b69c1f62da8c104370f85b436eac068524b965cc) (2024-09-06)

### Bugfixes

- Fix inconsistent rendering of reactions whose start time is in the current time interval, but whose end time is after the current time interval.
  - This change affects the following panel: "Reaction executions (red indicates deadline violation)."
  - Before:
    ![before](docs/images/changelog/2024-09-06/before-inconsistent-rendering.png)
  - After:
    ![after](docs/images/changelog/2024-09-06/after-inconsistent-rendering-and-other-fix.png)

### Improvements

- Report timing data at reaction granularity, not reactor granularity.

  - It will still be clear what the containing reactor is of each reaction based on the descriptions given to the reactions. For example, "c_producer reaction 1" indicates that the containing reactor is `c_producer`.
  - This change affects the following panels: "Maximum lag per reactor over logical time," "Reaction executions (red indicates deadline violation)," "Reaction executions (opacity indicates logical time and microstep)," and "Deadline violations per scheduled reaction execution."
  - Before:
    ![before](docs/images/changelog/2024-09-06/before-reactions-not-reactors.png)
  - After:
    ![after](docs/images/changelog/2024-09-06/after-reactions-not-reactors.png)

- Use color coding and labelling to indicate when a reaction execution, deadline handler execution, or idle period corresponds to only part of a time interval due to the end point not being in the current time window.
  - This change is motivated by the fact that when a reaction execution does not terminate in the current time window, the duration that is reported by the tooltip for these panels corresponds only to the portion of the time interval that overlaps with the current time window. Therefore, it is necessary to clarify that the time interval reported only corresponds to a part of a larger time interval.
  - Panel descriptions are updated to explain this and its relevance to reported interval durations.
  - This change affects the following panels: "Reaction executions (red indicates deadline violation)" and "Reaction executions (opacity indicates logical time and microstep)"

## [8ebc9b5](https://github.com/xronos-inc/xronos-dashboard/tree/8ebc9b504e602259b7ccfe64fc43a0a0e206c573) (2024-08-05)

### Bugfixes

- Update the dashboard to include fixes for incorrect end times and dropped reaction executions that used to appear in the reaction execution timelines.
  - This also changes the panel titled "Reaction executions (opacity indicates logical time and microstep)" to use opacity to indicate logical time and microstep instead of using color to indicate logical time. This can make the panel difficult to read without zooming in, but for technical reasons, it is necessary in order to enable this bugfix.
  - Example 1:
    - Before this bugfix, reaction executions are often dropped or reported as having the wrong execution times, seemingly at random:
      ![before](docs/images/changelog/2024-08-05/multi_tread_master.png)
    - After this bugfix, reaction executions are reported correctly, clearly showing that we periodically execute a 50-millisecond reaction in reactor `a` followed by short-running reactions in the other reactors:
      ![after](docs/images/changelog/2024-08-05/multi_tread_corrected.png)
  - Example 2 is similar to example 1:
    - Before:
      ![before](docs/images/changelog/2024-08-05/single_tread_master.png)
    - After:
      ![after](docs/images/changelog/2024-08-05/single_tread_corrected.png)
- Fix a bug involving unclear and non-unique names that made the "Reaction WCET" panel difficult to interpret. This panel now reports distinct data for each reaction and does not aggregate data across distinct reactions in the same federate.
  - Before:
    ![before](docs/images/changelog/2024-08-05/reaction-wcets-master.png)
  - After:
    ![after](docs/images/changelog/2024-08-05/reaction-wcets-corrected.png)

### Improvements

- Update the dashboard with descriptions to clarify the intended meaning of certain visualizations.
- Rework the time series panel which is now called "Maximum lag by logical time." Notably, this changes it so that the x-axis is logical time, not physical time. We believe that this makes the data in the panel more interpretable, although it can result in data not appearing in the panel when the difference between logical and physical time is large relative to the size of the current time window.
- Remove the panel called "Logical time by reactor." We believe that this panel provides no additional information beyond what now appears in the panel titled "Reaction executions (opacity indicates logical time and microstep)." Additionally, the panel can be difficult to understand.
- Add a panel that reports the frequency of deadline misses per reactor.

### Non-dashboard changes

- Change variable names in the example programs to avoid naming collisions. A more robust and general fix that uses IDs to distinguish between different programs that use the same FQNs is left for a future PR.
- Add an "examples" directory, including an example that demonstrates correct reporting of deadline violations.
