# Tools Layer

The **Tools Layer** defines the policies and inventory for existing, custom, and integrated software utilities in Project Atlas.

## Tool Creation Hierarchy
To minimize maintenance and complexity, building new tools is always the **last option**.

```
1. Existing Built-in Features (기존 기능 사용)
   └── 2. Existing Add-ons/Plugins (기존 애드온 사용)
         └── 3. Open Source Software (오픈소스 사용)
               └── 4. Lightweight Scripts (간단한 스크립트 작성 - Python, Bash, Node)
                     └── 5. Custom Blender Add-ons (Blender Addon 제작)
                           └── 6. Custom Unreal Engine Plugins (UE Plugin 제작)
                                 └── 7. Dedicated New Programs (새 프로그램 제작) [LAST RESORT]
```

## Inventory Policy
- Register tools in this layer with their documentation, dependencies, and license status.
- Prioritize scripting over compiling binary plugins to keep code readable and portable.
