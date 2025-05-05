

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
    
    
class rem_constraint(bpy.types.Operator):
    bl_idname = "wm.remove_constraint"
    bl_label = "Minimal Operator"

    def execute(self, context):
        # Report "Hello World" to the Console
        
        bones = bpy.context.object.pose.bones
        i = 0 
        for bone in bones:
            
            bpy.context.object.data.bones.active = bone.bone
            bone.bone.select = True
            
            bpy.ops.constraint.delete(constraint="Copy Transforms", owner='BONE')
            i += 1
        self.report({'INFO'}, "Hello World")
        return {'FINISHED'}


bpy.utils.register_class(rem_constraint)


class WM_OT_HelloWorld(bpy.types.Operator):
    bl_idname = "wm.constrain_bones_spline" # this is the class name
    bl_label = "Minimal Operator"

    def execute(self, context):
        # Report "Hello World" to the Console
        
        bones = bpy.context.object.pose.bones
        i = 0 
        for bone in bones:
            
            bpy.context.object.data.bones.active = bone.bone
            bone.bone.select = True
            bpy.ops.pose.constraint_add(type='COPY_TRANSFORMS')
            print(bones[i].name)
            bpy.context.object.pose.bones[bones[i].name].constraints["Copy Transforms"].target = bpy.data.objects["Armature"]
            bpy.context.object.pose.bones[bones[i].name].constraints["Copy Transforms"].subtarget = bones[i].name
            i += 1
        self.report({'INFO'}, "Hello World")
        return {'FINISHED'}



bpy.utils.register_class(WM_OT_HelloWorld)


class app_constraint(bpy.types.Operator):
    bl_idname = "wm.apply_constraint"
    bl_label = "Minimal Operator"

    def execute(self, context):
        # Report "Hello World" to the Console
        
        bones = bpy.context.object.pose.bones
        i = 0 
        for bone in bones:
            
            bpy.context.object.data.bones.active = bone.bone
            bone.bone.select = True
            bpy.ops.constraint.apply(constraint="Copy Transforms", owner='BONE')
            i += 1
            
        self.report({'INFO'}, "Hello World")
        return {'FINISHED'}


bpy.utils.register_class(app_constraint)