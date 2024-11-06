

# give Python access to Blender's functionality
import bpy

class HelloWorldOperator(bpy.types.Operator):
    bl_idname = "wm.hello_world"
    bl_label = "Minimal Operator"

    def execute(self, context):
        print("Hello World")
        return {'FINISHED'}
    



class VIEW3D_PT_my_custom_panel(bpy.types.Panel):  # class naming convention ‘CATEGORY_PT_name’

    # where to add the panel in the UI
    bl_space_type = "VIEW_3D"  # 3D Viewport area (find list of values here https://docs.blender.org/api/current/bpy_types_enum_items/space_type_items.html#rna-enum-space-type-items)
    bl_region_type = "UI"  # Sidebar region (find list of values here https://docs.blender.org/api/current/bpy_types_enum_items/region_type_items.html#rna-enum-region-type-items)

    bl_category = "snake animator tool"  # found in the Sidebar
    bl_label = "snake animator tool"  # found at the top of the Panel

    def draw(self, context):
        """define the layout of the panel"""
        row = self.layout.row()
        row.operator("wm.constrain_bones_spline", text="Constrain BONES")
        row = self.layout.row()
        row.operator("wm.remove_constraint", text="remove constraints")
        row = self.layout.row()
        row.operator("wm.apply_constraint", text="Apply Constraints")


def register():
    bpy.utils.register_class(VIEW3D_PT_my_custom_panel)


def unregister():
    bpy.utils.unregister_class(VIEW3D_PT_my_custom_panel)

    



if __name__ == "__main__":
    register()