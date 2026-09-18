# Atlas v1.1 Roadmap: Environment-Aware DevOS

## Key Enhancements
- **ENVIRONMENT_REGISTRY** implementation for dynamic environment switching
- Integration with `ATLAS_STATE.json` for context-aware task recommendation
- Enhanced `atlas_runner` with environment-specific workflow prioritization
- Priority Engine updates to handle environment constraints

## Milestones
1. **Environment Registry Definition**  
   - Completed: `ENVIRONMENT_REGISTRY.md` documentation  
   - Implemented: `core/registry/environment_registry.py`

2. **State Integration**  
   - Updated `ATLAS_STATE.json` to include `active_environment` field

3. **Runner Enhancements**  
   - `atlas_runner.py` now validates environment capabilities before task execution

4. **Priority Engine Update**  
   - Added environment constraint checks in `core/decision/priority_engine.py`

## Next Steps
- Implement environment-aware task filtering in `atlas_runner`
- Add environment-specific workflow rules
- Develop UI for environment status visualization