camera = webcam('iPhone Camera');
net = alexnet;
inputSize = net.Layers(1).InputSize(1:2);
figure;
while true
    I = snapshot(camera);
    image(I);
    f = imresize(I, inputSize);
    [label, score] = classify(net, f);
    title({char(label), num2str(max(score), 2)});
    drawnow;
end