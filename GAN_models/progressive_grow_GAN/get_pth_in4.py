import torch

pth_file_path = "D:\\DS-AI\\train\\check_points\\check_point_epoch_16.pth"
checkpoint = torch.load(pth_file_path, map_location=torch.device('cpu'))
print("Type of checkpoint:", type(checkpoint))


def print_checkpoint_info():
    if isinstance(checkpoint, dict):
        print("Keys in .pth file:", list(checkpoint.keys()))
        for key, value in checkpoint.items():
            print(f"\nKey: {key}")
            if isinstance(value, dict):
                print(f"  Type: Dictionary, Sub-keys: {list(value.keys())}")
                for sub_key, sub_value in value.items():
                    if isinstance(sub_value, torch.Tensor):
                        print(f"    Sub-key: {sub_key}, Shape: {sub_value.shape}")
                    else:
                        print(f"    Sub-key: {sub_key}, Type: {type(sub_value)}")
            elif isinstance(value, torch.Tensor):
                print(f"  Type: Tensor, Shape: {value.shape}")
            else:
                print(f"  Type: {type(value)}, Value: {value}")
    else:
        print("Content:", checkpoint)

    if isinstance(checkpoint, dict) and 'state_dict' in checkpoint:
        print("\nState_dict parameters:")
        for param_name, param_value in checkpoint['state_dict'].items():
            print(f"Parameter: {param_name}, Shape: {param_value.shape}")


def print_checkpoint_config_info():
    config = checkpoint['D_net']

    print("Type of config:", type(config))

    print("\nAttributes and methods of config:")
    for attr in dir(config):
        if not attr.startswith('__'):
            try:
                value = getattr(config, attr)
                print(f"{attr}: {value}")
            except AttributeError:
                print(f"{attr}: Cannot access")


print_checkpoint_info()
# print_checkpoint_config_info()
