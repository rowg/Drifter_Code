clear all
close all

coastFileName = 'COCMP_Big_mercat.mat';
% % % mnty_mask = load('MNTYMask.txt');
% % % anvo_mask = load('ANVOMask.txt');
% % % sfoo_mask = load('SFOOMask.txt');


figure
lims=[-123.333,-121.75,35.95,38.15]
plotBasemap(lims(1:2),lims(3:4),coastFileName,'mercator','patch','g');
hold on
% % % m_plot(sfoo_mask(:,1),sfoo_mask(:,2),'r')
% % % m_plot(mnty_mask(:,1),mnty_mask(:,2),'r')
% % % m_plot(anvo_mask(:,1),anvo_mask(:,2),'k')

load MNTY_OMA_Boundary
m_plot(OMA_boundary(:,1),OMA_boundary(:,2),'b-','linewidth',2)
load ANVO_OMA_Boundary
m_plot(OMA_boundary(:,1),OMA_boundary(:,2),'r-','linewidth',2)
load SFOO_OMA_Boundary
m_plot(OMA_boundary(:,1),OMA_boundary(:,2),'b-','linewidth',2)

title('COCMP OMA Subdomains','fontsize',20);
