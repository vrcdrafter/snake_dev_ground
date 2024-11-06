import bpy

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

# test call the operator

bpy.ops.wm.apply_constraint()