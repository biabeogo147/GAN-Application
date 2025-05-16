import onnx
import os.path
import onnxruntime
from utils.utils import *
from model import Generator, Discriminator

model_pt_path = os.path.join(model_path, 'last.pt')
gen_model_onnx_path = os.path.join(model_path, 'generator.onnx')
dis_model_onnx_path = os.path.join(model_path, 'discriminator.onnx')
noise = (torch.randn(1, nz, 1, 1, device=device), )
fake_img = None


def export_to_onnx():
    netG = Generator(ngpu).to(device)
    netD = Discriminator(ngpu).to(device)

    if os.path.exists(model_pt_path):
        print("Getting checkpoint...")
        checkpoint = torch.load(model_pt_path, map_location=torch.device(device))
        netD.load_state_dict(checkpoint["model_state_dict_Discriminator"])
        netG.load_state_dict(checkpoint["model_state_dict_Generator"])
        print("Checkpoint loaded")

    netG.eval()
    onnx_gen_program = torch.onnx.export(netG, noise, dynamo=True)
    onnx_gen_program.optimize()
    onnx_gen_program.save(gen_model_onnx_path)
    onnx_model = onnx.load(gen_model_onnx_path)
    onnx.checker.check_model(onnx_model)


    netD.eval()
    fake_img = (netG(noise[0]), )
    onnx_dis_program = torch.onnx.export(netD, fake_img, dynamo=True)
    onnx_dis_program.optimize()
    onnx_dis_program.save(dis_model_onnx_path)
    onnx_model = onnx.load(dis_model_onnx_path)
    onnx.checker.check_model(onnx_model)

    print("Exported to ONNX format successfully.")


def inference_gen_model_onnx():
    onnx_inputs = [tensor.numpy(force=True) for tensor in noise]
    print(f"Input length: {len(onnx_inputs)}")

    ort_session = onnxruntime.InferenceSession(
        gen_model_onnx_path, providers=["CPUExecutionProvider"]
    )

    onnxruntime_input = {input_arg.name: input_value for input_arg, input_value in zip(ort_session.get_inputs(), onnx_inputs)}
    onnxruntime_outputs = ort_session.run(None, onnxruntime_input)[0]

    plt.imshow(np.transpose(vutils.make_grid(torch.from_numpy(onnxruntime_outputs), padding=2, normalize=True), (1, 2, 0)))
    plt.axis("off")
    plt.show()


def inference_pt():
    netG = Generator(ngpu).to(device)
    if os.path.exists(os.path.join(model_path, 'last.pt')):
        print("Loading checkpoint...")
        checkpoint = torch.load(os.path.join(model_path, 'last.pt'), map_location=torch.device(device))
        netG.load_state_dict(checkpoint["model_state_dict_Generator"])
        print("Checkpoint loaded")

    fixed_noise = torch.randn(64, nz, 1, 1, device=device)
    fake = netG(fixed_noise).detach().cpu()

    plt.figure(figsize=(8, 8))
    plt.imshow(np.transpose(vutils.make_grid(fake, padding=2, normalize=True), (1, 2, 0)))
    plt.axis("off")
    plt.show()


if __name__ == '__main__':
    # inference_pt()
    # export_to_onnx()
    inference_gen_model_onnx()